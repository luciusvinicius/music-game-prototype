extends Node

@onready var timer : Timer = $Timer
@onready var audio : AudioStreamPlayer = $Audio

@export var bpm = 60:
	set(new_value):
		beat_length = 60 / new_value
		timer.wait_time = beat_length
		bpm = new_value

# Signals
signal beat_played
signal measure_played

# Vars
var beat_length
var current_beat 
var current_note_idx := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	beat_length = 60 / bpm

func play(beat_name: String):
	current_beat = Beats.get_beat(beat_name)
	current_note_idx = -1
	setup_next_note()
	timer.start()

func stop():
	timer.stop()

func setup_next_note():
	# Update indexes
	var current_note = current_beat.notes[current_note_idx]
	current_note_idx = (current_note_idx + 1) % current_beat.notes.size()
	var next_note = current_beat.notes[current_note_idx]
	
	# Update wait time for timer
	var wait_time
	if next_note.time == 0:
		wait_time = beat_length * (current_beat.measure * 60 - current_note.time) / 60.0 # measure * 60 is the upper limit (240 for 4, 180 for 3, etc...)
	else:
		wait_time = beat_length * (next_note.time - current_note.time) / 60.0
	timer.wait_time = wait_time
	
func _on_timer_timeout():
	# Play audio and create the setup for the next one
	var next_note = current_beat.notes[current_note_idx]
	audio.stream = next_note.stream	
	audio.play()
	setup_next_note()
	
	# Emit signals
	beat_played.emit()
	if current_note_idx == 0: measure_played.emit()
