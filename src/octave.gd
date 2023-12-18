extends Node2D

@export_range(-2, 2, 1) var octave := 0
@onready var keys = $Keys


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Setup keys pitches
	for key in keys.get_children():
		var key_idx = Consts.get_note_idx(key.name)
		var pitch = 2**(key_idx/12.0) * 2.0**octave
		key.pitch = pitch

