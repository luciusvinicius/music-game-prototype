class_name Consts

extends Node

static var NOTES_ORDER = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

static func get_note_idx(note: String) -> int:
	return NOTES_ORDER.find(note)
