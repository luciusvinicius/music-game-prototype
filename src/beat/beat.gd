extends Node

## -- || Nodes || --
@onready var audio : AudioStreamPlayer = $Audio

## -- || Vars || --
var current_beat 
var current_note_idx := 0
var time := 0.0
var reseted_idx := false # Avoids playing note with time = 0 after playing last note (before looping)
@export var bpm := 60.0:
	set(new_value):
		bpm = new_value
		SignalManager.bpm_updated.emit(bpm)
		reset()



### --- || Code || ---
func _process(delta):
	if bpm == 0.0 or current_beat == null: return
	
	var current_note = current_beat.notes[current_note_idx]
	time += delta * bpm
	
	# If note should be played
	if time >= current_note.time and not reseted_idx:
		play_note(current_note)
		reseted_idx = setup_next_note()
	
	# Reset beat loop
	if time >= current_beat.measure * 60.0:
		time -= current_beat.measure * 60.0
		reseted_idx = false
		SignalManager.measure_played.emit()

func play(beat_name: String):
	current_beat = Beats.get_beat(beat_name)
	SignalManager.update_measure.emit(current_beat.measure)
	current_note_idx = -1
	setup_next_note()

func stop():
	audio.stop()
	current_beat = null

func setup_next_note() -> bool:
	# Update indexes
	current_note_idx = (current_note_idx + 1) % current_beat.notes.size()
	return current_note_idx == 0 # Returns if the index should be reseted

func play_note(note):
	audio.stream = note.stream	
	audio.play()
	SignalManager.beat_played.emit()

func reset():
	current_note_idx = 0
	time = 0.0
	reseted_idx = 0
