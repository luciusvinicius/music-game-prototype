extends Node2D

@export var octave := 0:
	set(new_value):
		# Ignore before ready exists
		if not is_instance_valid(keys): return 
		octave = new_value
		setup_keys_pitches()

@onready var keys = $Keys


# Called when the node enters the scene tree for the first time.
func _ready():
	setup_keys_pitches()

func setup_keys_pitches():
	for key in keys.get_children():
		var key_idx = Consts.get_note_idx(key.name)
		var pitch = 2.0**octave * 2**(key_idx/12.0)
		key.pitch = pitch
		key.octave = octave

func press_key(key_idx):
	var key = keys.get_child(key_idx)
	key.automatic_press_key()

func press_tutorial_key(key_idx):
	var key = keys.get_child(key_idx)
	key.tutorial_press_key()

func release_key(key_idx):
	var key = keys.get_child(key_idx)
	key.release_key(true) # Ignore_signal
