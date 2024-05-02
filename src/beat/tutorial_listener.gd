extends Node

const CLOSEST_NOTE_SCORE_MULTIPLIER = 100.0

@onready var current_song = null
var measure := 4
var measures_played := 0
var is_playing := false
var next_note_idx := 0

func _ready():
	SignalManager.start_tutorial.connect(_on_tutorial_start)
	SignalManager.update_measure.connect(_update_measure)
	SignalManager.measure_played.connect(_reset_measure)
	SignalManager.key_pressed.connect(_read_key_press)
	SignalManager.tutorial_ended.connect(_on_tutorial_end)

# Old Edition
# func _generate_tutorial_score(closest_note, pressed_key_idx, pressed_time):

# 	## Time Score
# 	var time_score = 0
# 	var note_time = closest_note.time
# 	# Improve later with a while loop
# 	if _check_if_on_beat(note_time, pressed_time, 1.0):
# 		time_score = 100
# 	elif _check_if_on_beat(note_time, pressed_time, 2.0):
# 		time_score = 90
# 	elif _check_if_on_beat(note_time, pressed_time, 4.0):
# 		time_score = 70
# 	elif _check_if_on_beat(note_time, pressed_time, 8.0):
# 		time_score = 30
# 	else:
# 		time_score = 0
# 	print("time_score: ", time_score)

# 	## Note Score
# 	# If they are the same note, optimal score. Loses score the further away it is
# 	var note_score = CLOSEST_NOTE_SCORE_MULTIPLIER / (abs(closest_note.note - pressed_key_idx) + 1)
# 	print("note_score: ", note_score)

# 	SignalManager.tutorial_key_pressed_score.emit(time_score + note_score)

func _generate_tutorial_score(closest_note, pressed_key_idx):

	## Note Score
	# If they are the same note, optimal score. Loses score the further away it is
	var note_score = CLOSEST_NOTE_SCORE_MULTIPLIER / (abs(closest_note.note - pressed_key_idx) + 1)
	var is_correct = note_score == CLOSEST_NOTE_SCORE_MULTIPLIER
	
	if is_correct:
		next_note_idx += 1

	SignalManager.tutorial_key_pressed.emit(closest_note, note_score == CLOSEST_NOTE_SCORE_MULTIPLIER)

func _check_if_on_beat(note_time:float, pressed_time:float, multiplier:float):

	# Considers until quarter note
	if abs(note_time - pressed_time) <= Consts.HITTING_ON_BEAT_ERROR_MARGIN * multiplier \
			or pressed_time <= Consts.HITTING_ON_BEAT_ERROR_MARGIN * multiplier:
		return true
	return false


## -- || Key Signals || --

func _read_key_press(key):
	if not is_playing: return
	var key_idx = Consts.get_note_idx(key.name)
	var octave_idx = _get_octave_idx(key)
	var note_val = octave_idx * 12 + key_idx

	# Compare to song's closest note
	var correct_note = current_song.notes[next_note_idx]

	_generate_tutorial_score(correct_note, note_val)

# func _read_key_press(key):
# 	if not is_playing: return
# 	var key_idx = Consts.get_note_idx(key.name)
# 	var octave_idx = _get_octave_idx(key)
# 	var note_val = octave_idx * 12 + key_idx

# 	# Compare to song's closest note
# 	var pressed_time = Global.time + 60.0 * measures_played * measure
# 	var closest_note = _get_closest_note(pressed_time)

# 	_generate_tutorial_score(closest_note, note_val, pressed_time)

func _get_octave_idx(key):
	var parent_octave = key.get_parent().get_parent()
	var octave_idx = 0
	for octave in parent_octave.get_parent().get_children():
		if octave == parent_octave: break
		octave_idx += 1
	return octave_idx

func _get_closest_note(time):
	# var MIX = {
	# 	"name": "Mix",
	# 	"measures": 4,
	# 	"notes": _produce_notes([7, 19, 7, 19], [60, 60, 60, 60])
	# }
	# song_notes.append({"note": note, "duration": duration})

	var closest_note = current_song.notes[0]
	var total_time = 0.0
	for note in current_song.notes:
		if time < total_time + note.duration:
			if abs(time - total_time) < abs(time - (total_time + note.duration)):
				closest_note = note
			break
		total_time += note.duration
		closest_note = note

	return {"note": closest_note.note, "time": total_time}

## -- || Other Signals || --
func _on_tutorial_start(song):
	current_song = song
	next_note_idx = 0

func _on_tutorial_end(_song):
	current_song = null
	is_playing = false
	measures_played = 0

func _reset_measure():
	measures_played += 1
	if current_song and not is_playing: # Start to play when beat loops
		is_playing = true
		measures_played = 0
	
func _update_measure(new_measure):
	measure = new_measure
