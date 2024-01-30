extends Node2D

@export var base_octave := 0
@onready var octaves = $Octaves

# Called when the node enters the scene tree for the first time.
func _ready():
	for octave in octaves.get_children():
		var new_octave = base_octave + octave.get_index()
		octave.octave = new_octave
	SignalManager.play_note_on_keyboard.connect(_play_note)

func _play_note(note):
	var octave_idx = note / 12
	var octave = octaves.get_child(octave_idx)
	octave.press_key(note % 12)
