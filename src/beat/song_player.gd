extends Node

## -- Vars -- ##
@onready var current_song = null
var previous_time := 0.0
var previous_duration := 0.0
var measure := 4
var measures_played := 0
var note_to_play := 0
var is_challenge := false
var is_playing := false

## -- Functions -- ##
func _ready():
	SignalManager.update_measure.connect(_update_measure)
	SignalManager.measure_played.connect(_reset_measure)

func play_song(song_name: String):
	current_song = Songs.get_song(song_name)
	reset()

func reset():
	note_to_play = 0
	measures_played = 0
	previous_time = 0.0
	previous_duration = 0.0
	is_challenge = false


func _process(_delta):
	if current_song == null or not is_playing: return
	var current_time = Global.time + 60.0 * measures_played * measure
	if current_time < previous_time: return
	if note_to_play >= current_song.notes.size():
		print("End of song")
		_release_last_note(note_to_play)
		current_song = null
		is_challenge = true # TODO: create gray notes for the player to press
		is_playing = false
		return
	_play_note_idx(note_to_play)
	note_to_play += 1
	

func _play_note_idx(note_idx):
	_release_last_note(note_idx)
	var current_note = current_song.notes[note_idx].note
	previous_time += current_song.notes[note_idx].duration
	SignalManager.play_note_on_keyboard.emit(current_note)

func _release_last_note(note_idx):
	if note_idx > 0:
		var previous_note = current_song.notes[note_idx - 1].note
		SignalManager.release_note_on_keyboard.emit(previous_note)

## -- Signals -- ##
func _update_measure(new_measure):
	measure = new_measure

func _reset_measure():
	measures_played += 1
	if current_song and not is_playing: # Start to play when beat loops
		is_playing = true
		measures_played = 0
