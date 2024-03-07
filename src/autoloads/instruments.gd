extends Node

const FLUTE = preload("res://assets/instruments/c_flute.mp3")
const PIANO = preload("res://assets/instruments/c_piano.mp3")
const STEEL_GUITAR = preload("res://assets/instruments/c_steel_guitar.mp3")

const INSTRUMENTS = [
	{
		"name": "Piano",
		"stream": PIANO
	},
	{
		"name": "Flute",
		"stream": FLUTE
	},
	{
		"name": "Steel\nGuitar",
		"stream": STEEL_GUITAR
	}
]

func get_instrument(instrument_name: String):
	var possible_instruments := INSTRUMENTS.filter(func(i): return i.name == instrument_name)
	if possible_instruments.size() == 0:
		push_error("Instrument of name %s not found!" % instrument_name)
		return null
	var instrument = possible_instruments[0]
	return instrument
