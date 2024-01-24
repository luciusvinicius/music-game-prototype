extends Node

# Queue = [Time1, Time2]
# Time = {loop: 0, time: 0.0, note: note_key, duration: 0.0, has_played: false, has_released: false} # Duration maybe solved another day

## -- || Vars || --
var queue : Array[Dictionary] = []
var measure := 4
var measures_looped := 0
var loop_number := 0
var time := 0.0
var bpm := 60.0

### --- || Code || ---

## -- || Main Loop || --

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.update_measure.connect(_update_measure)
	SignalManager.measure_played.connect(_reset_loop)
	SignalManager.melodies_in_loop_changed.connect(_update_measures_looped)
	SignalManager.bpm_updated.connect(_update_bpm)
	SignalManager.key_pressed.connect(_read_key_press)
	SignalManager.key_released.connect(_read_key_release)

func _update_measure(val):
	measure = val
	time = 0.0

func _reset_loop():
	loop_number += 1
	time -= min(bpm * measure, time) # time-time=0 is a fail-proof in the case that BPM was changed midway
	
	# Remove previous loop entries
	var old_keys = queue.filter(func(key): return loop_number - measures_looped > key.loop)
	for key in old_keys:
		queue.erase(key)
	
	# Renew previously played notes
	for key in queue:
		key.has_played = false
		key.has_released = false


func _update_measures_looped(value):
	measures_looped = value

func _update_bpm(new_bpm):
	bpm = new_bpm
	time = 0.0
	

func _process(delta):
	if bpm == 0.0: return
	
	time += delta * bpm
	
	# Verify if there are notes on the queue to play
	var possible_notes = queue.filter(func(key): return time > key.time \
	 and loop_number - key.loop > 0) # Needs second condition to not play immediately
	
	var notes_to_play = possible_notes.filter(func(key): return not key.has_played)
	var notes_to_release = possible_notes.filter(func(key): return time > key.time + key.duration \
	 and not key.has_released)
	
	# Play/release every note in time
	for key in notes_to_play:
		key.note.automatic_press_key() # Ignore emited signal
		key.has_played = true
	
	for key in notes_to_release:
		key.note.release_key(true)
		key.has_releasedd = true


## -- || Key Inputs || --

# Time = {loop: 0, time: 0.0, note: note_key, duration: 0.0, has_played: false} # Duration maybe solved another day
func _read_key_press(key):
	var note = {}
	note.loop = loop_number
	note.time = time
	note.note = key
	note.duration = 0.0 # TODO
	note.has_played = false
	note.has_released = false
	
	queue.append(note)

func _read_key_release(key):
	# TODO doesn't work for notes that relase after loop i think
	var notes = queue.filter(func(k): return k.note == key and k.duration == 0.0) # Only one of those can exist
	
	if notes.size() != 1:
		print("Fodeu")
	
	if notes.size() == 1:
		var note = notes[0]
		var note_duration = time - note.time
		# If note would overflow, cap it at the maximum time
		if note_duration < 0:
			note_duration = (60 * measure) - note.time
		note.duration = note_duration