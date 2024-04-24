extends Node

const HITTING_ON_BEAT_ERROR_MARGIN = 3 # in beat time
var NOTES_ORDER = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
var NOTES_REGULAR_ORDER = {
	"C": 0,
	"C#": 0,
	"D": 1,
	"D#": 1,
	"E": 2,
	"F": 3,
	"F#": 3,
	"G": 4,
	"G#": 4,
	"A": 5,
	"A#": 5,
	"B": 6
}

var NOTES_DURATION2NAME = {
	30: "eighth",
	60: "quarter",
	120: "half"
}

func get_note_idx(note: String) -> int:
	return NOTES_ORDER.find(note)
