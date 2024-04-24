extends Node2D

@export var base_octave := 0
@onready var octaves = $Octaves

const MAP_TO_CORRECT_IDX = {
	0: 0,
	1: 7,
	2: 1,
	3: 8,
	4: 2,
	5: 3,
	6: 9,
	7: 4,
	8: 10,
	9: 5,
	10: 11,
	11: 6,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	for octave in octaves.get_children():
		var new_octave = base_octave + octave.get_index()
		octave.octave = new_octave
	SignalManager.play_note_on_keyboard.connect(_play_note)
	SignalManager.play_tutorial_note_on_keyboard.connect(_play_tutorial_note)
	SignalManager.release_note_on_keyboard.connect(_release_note)

func _play_note(key):
	var octave_idx = key.note / 12
	var octave = octaves.get_child(octave_idx)
	octave.press_key(MAP_TO_CORRECT_IDX[key.note % 12])

func _play_tutorial_note(key):
	var octave_idx = key.note / 12
	var octave = octaves.get_child(octave_idx)
	octave.press_tutorial_key(MAP_TO_CORRECT_IDX[key.note % 12])

func _release_note(key):
	var octave_idx = key.note / 12
	var octave = octaves.get_child(octave_idx)
	octave.release_key(MAP_TO_CORRECT_IDX[key.note % 12])
