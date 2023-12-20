extends Node

const KICK = preload("res://assets/beats/kick.mp3")
const SNARE = preload("res://assets/beats/snare.mp3")
# BEATS will follow the following structure:
# Beats: [Beat1, Beat2, ...]
# Beat: {"name": "Beat1", "measures": 4, "notes": [Note1, Note2, ...]}
# Note: {"stream": STREAM_SOUND, "time": val} --> this "time" will be when the sound will appear on the beat
# It considers that a full cycle has 240 (60xMeasure=4) units of "time"

func get_beat(beat_name: String) -> Beat:
	var possible_beats := BEATS.filter(func(b): return b.name == beat_name)
	if possible_beats.size() == 0:
		push_error("Beat of name %s not found!" % beat_name)
		return null
	var beat = possible_beats[0]
	var beat_instance = Beat.new(beat.name, beat.measure, beat.notes)
	return beat_instance

class Beat:
	var beat_name:String
	var measure:int
	var notes:Array
	
	func _init(_name:String, _measure:int, _notes:Array):
		beat_name = _name
		measure = _measure
		notes = _notes
	


const BEATS = [
	{
		"name": "Beat 1",
		"measure": 4,
		"notes": [
			{
				"stream": KICK,
				"time": 0 
			},
			{
				"stream": SNARE,
				"time": 60
			},
			{
				"stream": KICK,
				"time": 120
			},
			{
				"stream": SNARE,
				"time": 150
			},
			{
				"stream": SNARE,
				"time": 180
			},
		]
	}
]
