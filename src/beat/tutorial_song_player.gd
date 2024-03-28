extends Node

## -- Vars -- ##
@onready var current_song = null
var note_to_play := 0
var is_playing := false

## -- Functions -- ##
func _ready():
	SignalManager.start_tutorial.connect(_start_tutorial)
	SignalManager.key_pressed.connect(_recv_key_press)

func reset(song_name):
	current_song = Songs.get_song(song_name)
	note_to_play = -1
	_play_next_note()

func _play_next_note():
	note_to_play += 1
	# Last note played
	if note_to_play >= current_song.notes.size():
		is_playing = false
		SignalManager.tutorial_ended.emit(current_song)
		current_song = null
		return

	var current_note = current_song.notes[note_to_play].note
	SignalManager.play_tutorial_note_on_keyboard.emit(current_note)


## -- Signals -- ##
func _recv_key_press(key):
	var current_note = current_song.notes[note_to_play].note
	var pressed_key_val = (key.octave + 1) * 12 + Consts.get_note_idx(key.name)

	if pressed_key_val == current_note:
		_play_next_note()
	# else:
	# 	SignalManager.play_wrong_note.emit()

func _start_tutorial(song):
	reset(song.name)
