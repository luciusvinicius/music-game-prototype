extends Node

var song_level = 0


# Structure is similar to beats, but instead of having a stream, it shows the note in the piano to be played.
# SONGS will follow the following structure:
# Songs: [Song1, Song2, ...]
# Song: {"name": "Song1", "measures": 4, "notes": [Note1, Note2, ...]}
# Note: {"note": 54, "duration": val} --> this "duration" will be when the sound will appear on the beat
# OBS.: "Note.note" is the child number of the keyboard node. 0 is C and 11 is B, multipliying for other octaves. 
# It considers that a full cycle has 240 (60xMeasure=4) units of "time"

func get_song(song_name: String):
	var possible_songs := SONGS.filter(func(s): return s.name == song_name)
	if possible_songs.size() == 0:
		push_error("Song of name %s not found!" % song_name)
		return null
	var song = possible_songs[0]
	return song


var FUR_ELISE_NOTES = [16, 15, 16, 15, 16, 11, 14, 12, 9,      0, 4, 9, 11,  4, 8, 11, 12]
var FUR_ELISE_DURATIONS = [60, 60, 60, 60, 60, 60, 60, 60, 120, 60, 60, 60, 120, 60, 60, 60, 120]

var FUR_ELISE = {
	"name": "Fur Elise",
	"measures": 4,
	"notes": _produce_notes(FUR_ELISE_NOTES, FUR_ELISE_DURATIONS)
}

var TUTORIAL = {
	"name": "Tutorial",
	"measures": 4,
	"notes": _produce_notes([7, 19, 7, 19], [60, 60, 60, 60])
}

var SONGS = [TUTORIAL, FUR_ELISE]


func _produce_notes(notes: Array, durations: Array):
	var song_notes = []

	# Both arrays have same length
	for i in range(notes.size()):
		var note = notes[i]
		var duration = durations[i]
		song_notes.append({"note": note, "duration": duration})

	return song_notes

func get_challenge_song():
	return SONGS[song_level]

func increase_song_level():
	song_level += 1

func get_next_song() -> String:
	if song_level >= SONGS.size():
		return ""
	return SONGS[song_level].name
