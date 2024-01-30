extends Node

## -- || Nodes || --
@onready var audio : AudioStreamPlayer = $Audio

## -- || Vars || --
var current_beat = Beats.get_beat("No Beat")
var current_note_idx := 0
var reseted_idx := false # Avoids playing note with time = 0 after playing last note (before looping)
@export var bpm := 60.0:
	set(new_value):
		bpm = new_value
		SignalManager.bpm_updated.emit(bpm)
		reset()

### --- || Code || ---
func _process(delta):
	if bpm == 0.0: return
	Global.time += delta * bpm
	
	if current_beat.notes.size() != 0: # Used for "No beat"
		var current_note = current_beat.notes[current_note_idx]
		
		# If note should be played
		if Global.time >= current_note.time and not reseted_idx:
			play_note(current_note)
			reseted_idx = setup_next_note()
		
	# Reset beat loop
	if Global.time >= current_beat.measure * 60.0:
		Global.time -= current_beat.measure * 60.0
		reseted_idx = false
		SignalManager.measure_played.emit()

func play(beat_name: String):
	current_beat = Beats.get_beat(beat_name)
	SignalManager.update_measure.emit(current_beat.measure)
	current_note_idx = -1
	setup_next_note(true)

func stop():
	audio.stop()
	current_beat = null
	SignalManager.update_measure.emit(0)

func setup_next_note(changed_beat:=false) -> bool:
	# Update indexes

	if changed_beat:
		for i in range(current_beat.notes.size()):
			if current_beat.notes[i].time > Global.time:
				current_note_idx = i - 1
				break

	if current_beat.notes.size() == 0: return true
	current_note_idx = (current_note_idx + 1) % current_beat.notes.size()
	return current_note_idx == 0 # Returns if the index should be reseted



func play_note(note):
	audio.stream = note.stream	
	audio.play()
	SignalManager.beat_played.emit()

func reset():
	current_note_idx = 0
	Global.time = 0.0
	reseted_idx = 0
