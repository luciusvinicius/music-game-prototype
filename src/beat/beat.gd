extends Node

const KICK = preload("res://assets/beats/kick.mp3")

@onready var timer : Timer = $Timer
@onready var audio : AudioStreamPlayer = $Audio

@export var bpm = 60:
	set(new_value):
		beat_length = 60 / new_value
		timer.wait_time = beat_length
		bpm = new_value

@export var measure = 4 # TODO: not used yet

var beat_length

# Called when the node enters the scene tree for the first time.
func _ready():
	beat_length = 60 / bpm


func play(beat):
	if beat:
		audio.stream = KICK
		timer.start()


func _on_timer_timeout():
	audio.play()
