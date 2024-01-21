extends Node

# Queue = [Time1, Time2]
# Time = {loop: 0, time: 0.0, note: note_key, duration: 0.0, is_playing: false} # Duration maybe solved another day

## -- || Vars || --
var queue : Array[Dictionary] = []
var measure := 4
var measures_looped := 0
var loop_number := 0
var time := 0.0
var bpm := 60.0

### --- || Code || ---

# Called when the node enters the scene tree for the first time.
func _ready():
	#SignalManager.beat_played.connect(_read_beat)
	SignalManager.update_measure.connect(_update_measure)
	SignalManager.measure_played.connect(_update_loop_number)
	SignalManager.key_pressed.connect(_read_key_press)
	SignalManager.melodies_in_loop_changed.connect(_update_measures_looped)
	SignalManager.bpm_updated.connect(_update_bpm)

func _update_measure(val):
	measure = val
	time = 0.0

func _update_loop_number():
	loop_number += 1
	time -= min(bpm * measure, time) # time-time=0 is a fail-proof in the case that BPM was changed midway
	
	# Remove previous loop entries
	var old_keys = queue.filter(func(key): return loop_number - measures_looped < key.loop)
	for key in old_keys:
		queue.erase(key)

func _update_measures_looped(value):
	measures_looped = value

func _update_bpm(new_bpm):
	bpm = new_bpm
	time = 0.0
	

func _process(delta):
	if bpm == 0.0: return
	
	time += delta * bpm
	# print("Sync time: ", time)
	# Verify if there are notes on the queue to play
	var possible_notes = queue.filter(func(key): return key.time < time and loop_number - key.loop > 0)
	var notes_to_play = possible_notes.filter(func(key): return not key.is_playing)
	
	# Play every note in time
	for key in notes_to_play:
		key.note.press_key(true) # Ignore emited signal
		key.is_playing = true

# Time = {loop: 0, time: 0.0, note: note_key, duration: 0.0, is_playing: false} # Duration maybe solved another day
func _read_key_press(key):
	var note = {}
	note.loop = loop_number
	note.time = time
	note.note = key
	note.duration = 0.0 # TODO
	note.is_playing = false
	queue.append(note)

