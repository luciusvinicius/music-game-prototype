extends Node
#
## [[{"key": Key, "time": X}, {...}], [...], ...] (one array for each melody looped
#var queue : Array = []
# [{"timer": Timer, "idx": X, "keys": [{"key": Key, "time": X}, {...}]}]
var timers : Array = [] # One for each melody

var loop_number := 0
var changed_measure := true

const TIMER_BASE_VALUE = 30 # Random high value for timer

# Called when the node enters the scene tree for the first time.
func _ready():
	#SignalManager.beat_played.connect(_read_beat)
	SignalManager.measure_played.connect(_read_measure)
	SignalManager.key_pressed.connect(_read_key_press)
	SignalManager.melodies_in_loop_changed.connect(_update_loop_number)


func _update_loop_number(value):
	loop_number = value

func _read_key_press(key):
	if timers.size() == 0: return
	print("Key press")
	var timer_dict = timers[-1]
	var timer = timer_dict.timer
	#var sel_queue: Array = queue[-1]
	var key_dict = {"key": key, "time": TIMER_BASE_VALUE - timer.time_left}
	timer.start() # Restart timer for next note
	timer_dict.keys.append(key_dict)
	#sel_queue.append(key_dict)

func _on_timer_timeout_play_note(timer_dict, key):
	print("Timer play note!", timer_dict)
	key.press_key()
	_prepare_timer(timer_dict)

func _prepare_timer(timer_dict):
	# MAJOR TODO: APPLY CALCULATIONS WITH BPM
	print("Prepare timer: ", timer_dict)
	var timer: Timer = timer_dict.timer
	var keys = timer_dict.keys
	# Stop if don't have next key to press
	if timer_dict.next_idx >= keys.size():
		print("No more next target")
		timer.stop()
		return
	
	var current_key = keys[timer_dict.next_idx]
	if timer.timeout.is_connected(_on_timer_timeout_play_note):
		timer.timeout.disconnect(_on_timer_timeout_play_note)
	
	# Update waiting time to play the note in the end
	timer.wait_time = current_key.time if current_key.time > 0.05 else 0.05 # It is possible to get bellow this somehow
	timer.timeout.connect(_on_timer_timeout_play_note.bind(timer_dict, current_key.key))
	timer_dict.next_idx += 1
	timer.start()
	

func _read_measure():
	## Timer
	# Stop current timer
	if timers.size() > 0:
		_prepare_timer(timers[-1])
	
	if timers.size() <= loop_number:
		var timer = Timer.new()
		timer.wait_time = TIMER_BASE_VALUE
		timers.append({"timer": timer, "next_idx": 0, "keys": []})
		add_child(timer)
		timer.start()
		
	else:
		# Offset timers to renew timers
		_allocate_array(timers, true)
		timers[-1].keys.clear()
		timers[-1].next_idx = 0

func _allocate_array(arr: Array, recycle := false):
	var oldest_value = arr[0]
	for i in range(0, arr.size() - 2):
			arr[i] = arr[i+1]
	if recycle:
		arr[-1] = oldest_value
	else:
		oldest_value.queue_free()
