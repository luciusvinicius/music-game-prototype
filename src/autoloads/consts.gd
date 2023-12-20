extends Node

var NOTES_ORDER = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

func get_note_idx(note: String) -> int:
	return NOTES_ORDER.find(note)
