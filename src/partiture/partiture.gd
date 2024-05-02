extends Control

# --- Preloads --- #

# Notes
const HALF = preload("res://assets/imgs/partiture/notes/half2.png")
const QUARTER = preload("res://assets/imgs/partiture/notes/quarter2.png")
const EIGHTH = preload("res://assets/imgs/partiture/notes/eighth.png")
const PARTITURE_NOTE_SCENE = preload("res://src/partiture/partiture_note.tscn")

# Sheet
const PARTITURE_MID = preload("res://assets/imgs/partiture/partiture_mid_transparent2.png")
const PARTITURE_END = preload("res://assets/imgs/partiture/partiture_end_transparent2.png")
const BLACK_RECTANGLE = preload("res://assets/imgs/partiture/white_rectangle.png")

# --- Nodes --- #
@onready var positions = $Positions
@onready var partiture_container = $ScrollContainer/PartitureContainer
@onready var scroll_container = $ScrollContainer
@onready var finished_tutorial_audio = $FinishedTutorialAudio

# --- Constants --- #
const SCROLL_SPEED_RATIO = 3
const NOTE_SPAWN_OFFSET_Y = 4
const NOTE_SPAWN_OFFSET_X = 12 * 5
const NOTE_MINIMUM_SIZE = Vector2(32, 54)
const PARTITURE_MINIMUM_SIZE = Vector2(256, 128)
const PARTITURE_SCROLL_OFFSET = 90
const SCROLL_LOOK_AHEAD_OFFSET = -150
const SCROLL_DISTANCE_RATIO = 1.85

# Group eighth notes
const BLACK_RECTANGLE_SIZE = Vector2(12 * 2.6, 8)
const BLACK_RECTANGLE_SHARP_SIZE = Vector2(12 * 3.25, 8)
const BLACK_RECTANGLE_MINIMUM_DISTANCE = 16
const GROUP_QUANTITY = 4

# Tutorial
const TUTORIAL_SCROLL_LOOK_AHEAD_OFFSET = -150 #-125

# --- Vars --- #
var note_type2texture = {
	"half": HALF,
	"quarter": QUARTER,
	"eighth": EIGHTH
}

var fisrt_note := true
var song_total_duration := 0
var total_duration_played := 0
var x_distance_traveled := 0.0

# Group notes
var current_note_group = []
var previous_partiture_idx = -1

# Tutorial Variables
var current_song
var current_note_idx := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.play_note_on_keyboard.connect(create_note)
	SignalManager.demo_song_started.connect(load_song_partiture)
	SignalManager.start_tutorial.connect(generate_tutorial_setup)
	SignalManager.tutorial_key_pressed.connect(on_tutorial_key_press)
	SignalManager.tutorial_ended.connect(on_tutorial_end)
	

# func _process(delta):
# 	# if fisrt_note:
# 	# 	return
# 	scroll_container.scroll_horizontal = round(scroll_value)
# 	# print(scroll_value)

func load_song_partiture(song):
	current_song = song
	previous_partiture_idx = -1
	scroll_container.scroll_horizontal = 0
	fisrt_note = true

	# Clean existence partiture
	total_duration_played = song.initial_offset
	x_distance_traveled = song.initial_offset
	for partiture in partiture_container.get_children():
		if "Start" in partiture.name or "End" in partiture.name:
			_remove_notes(partiture)
		else:
			partiture.queue_free()
	
	# Add mid partitures equivalent to song
	var mid_partitures_size = _get_mid_partitures_size(song)
	print("Mid Partitures Size: ", mid_partitures_size)
	for i in range(mid_partitures_size):
		var partiture_mid = TextureRect.new()
		partiture_mid.texture = PARTITURE_MID
		partiture_mid.custom_minimum_size = PARTITURE_MINIMUM_SIZE
		partiture_container.add_child(partiture_mid)
		var notes_node = Control.new()
		notes_node.name = "Notes"
		partiture_mid.add_child(notes_node)
		var bars_node = Control.new()
		bars_node.name = "Bars"
		partiture_mid.add_child(bars_node)
		partiture_container.move_child(partiture_mid, -2) # Add it to last, except the "partiture_end"
	
	# Change partiture end size (because original it's too short, it is an illusion lmao)
	var end_partiture = partiture_container.get_child(-1)
	end_partiture.texture = PARTITURE_END
	end_partiture.custom_minimum_size = PARTITURE_MINIMUM_SIZE

func generate_tutorial_setup(song):
	var tween = get_tree().create_tween()
	# tween.tween_property(scroll_container, "scroll_horizontal", 0, 1.0)

	# Make the notes gray
	for partiture in partiture_container.get_children():
		for note in partiture.get_node("Notes").get_children():
			note.become_transparent()
		# for bar in partiture.get_node("Bars").get_children():
			# var bar_tween = get_tree().create_tween()
			# bar_tween.tween_property(bar, "self_modulate", Colors.GRAY_TRANSPARENT, 1.0)
	
	current_note_idx = 0
	var first_key = song.notes[current_note_idx]
	total_duration_played = song.initial_offset
	x_distance_traveled = song.initial_offset
	print("Tutorial scroll")
	_animate_scroll(first_key, true)

func on_tutorial_key_press(key, is_correct):
	if not is_correct: return
	_animate_scroll(key, true)
	_turn_current_key_black()
	current_note_idx += 1

func on_tutorial_end(_song):
	if current_note_idx == 0: return
	current_note_idx = 0
	_turn_current_key_black()
	finished_tutorial_audio.play()

func create_demo_note(key):
	create_note(key, Colors.BLACK)

func create_note(key, color = Colors.BLACK):

	if fisrt_note:
		fisrt_note = false

	var note_node = PARTITURE_NOTE_SCENE.instantiate()
	note_node.initiate(key, color)

	## Spawn in correct position
	var octave_idx = key.note / 12
	var note_idx = key.note % 12
	var note_order = Consts.NOTES_ORDER[note_idx]
	var position_marker = positions.get_child(Consts.NOTES_REGULAR_ORDER[note_order])
	
	# Get partiture
	var partiture_idx = total_duration_played / 240 + 1
	var partiture = partiture_container.get_child(partiture_idx)
	if partiture_idx != previous_partiture_idx:
		previous_partiture_idx = partiture_idx
		current_note_group.clear()

	# Get X position
	var x_offset = (x_distance_traveled / (Songs.DURATION_PER_SHEET / 4)) * NOTE_SPAWN_OFFSET_X
	var y_offset = NOTE_SPAWN_OFFSET_Y - (octave_idx * 8 * 7)
	note_node.position = position_marker.position + Vector2(x_offset, y_offset)
	partiture.get_node("Notes").add_child(note_node)
	
	if note_node.is_eighth():
		_group_eights(note_node, partiture)
	else:
		current_note_group.clear()

	# Scroll Animation
	_animate_scroll(key)


func _group_eights(note, partiture):
	if current_note_group.size() == GROUP_QUANTITY:
		current_note_group.clear()
	
	current_note_group.append(note)
	if current_note_group.size() == 1: 
		return

	# Update note texture to default
	for note_node in current_note_group:
		note_node.become_group_texture()

	# Spawn a black rectangle if it doesn't exist

	var black_rectangle_node 
	if current_note_group.size() == 2:
		# Create a new rectangle
		black_rectangle_node = TextureRect.new()
		black_rectangle_node.texture = BLACK_RECTANGLE
		black_rectangle_node.self_modulate = Colors.BLACK
		var rectangle_size = BLACK_RECTANGLE_SHARP_SIZE if note.is_sharp() else BLACK_RECTANGLE_SIZE
		black_rectangle_node.custom_minimum_size = rectangle_size
		black_rectangle_node.position = current_note_group[0].get_bar_position()
		black_rectangle_node.set_deferred("size", rectangle_size)
		black_rectangle_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		partiture.get_node("Bars").add_child(black_rectangle_node)
		for note_node in current_note_group:
			if note_node.is_reverted():
				for note_node2 in current_note_group:
					note_node2.revert()
				break
		# print("Bar added in position: ", black_rectangle_node.position, " with Size: ", black_rectangle_node.size)
	
	else:
		# Update last bar size and position
		black_rectangle_node = partiture.get_node("Bars").get_child(-1)
		if note.is_sharp():
			black_rectangle_node.size.x += BLACK_RECTANGLE_SHARP_SIZE.x
		else:
			if current_note_group[-2].is_sharp():
				# Compensate for previous increment
				black_rectangle_node.size.x = (current_note_group.size()-1) * BLACK_RECTANGLE_SIZE.x
			else:
				black_rectangle_node.size.x += BLACK_RECTANGLE_SIZE.x
		

		# If a note in the group is reverted, every note becomes reverted
		for note_node in current_note_group:
			if note_node.is_reverted():
				for note_node2 in current_note_group:
					note_node2.revert()
				break
			
		# Offset bar to max/min position
		if note.is_reverted_texture() and black_rectangle_node.position.y < note.position.y:
			black_rectangle_node.position.y = note.position.y
		elif not note.is_reverted_texture() and black_rectangle_node.position.y > note.position.y:
			black_rectangle_node.position.y = note.position.y

	for note_node in current_note_group:
		note_node.update_stem_size(black_rectangle_node)


func _animate_scroll(key, is_tutorial := false):
	print("Key: ", key)
	# Update total duration played
	total_duration_played += key.duration

	x_distance_traveled += key.duration
	if x_distance_traveled >= Songs.DURATION_PER_SHEET:
		x_distance_traveled = 0

	# Animate scroll value
	var scroll_distance 
	if total_duration_played >= song_total_duration: # End of song
		scroll_distance = 3 * scroll_container.size.x
	else:
		scroll_distance = float(total_duration_played) / song_total_duration * scroll_container.size.x * SCROLL_DISTANCE_RATIO

		var offset = TUTORIAL_SCROLL_LOOK_AHEAD_OFFSET if is_tutorial else SCROLL_LOOK_AHEAD_OFFSET
		scroll_distance += offset

		# Add partiture size offset
		scroll_distance += total_duration_played / Songs.DURATION_PER_SHEET * PARTITURE_SCROLL_OFFSET 
	
	var scroll_time = float(key.duration) / Songs.DURATION_PER_SHEET * SCROLL_SPEED_RATIO
	var tween_scroll = get_tree().create_tween()
	tween_scroll.tween_property(scroll_container, "scroll_horizontal", scroll_distance, scroll_time)



# --- Other Functions --- #
func _remove_notes(node):
	for child in node.get_children():
		for grandchild in child.get_children():
			grandchild.queue_free()
	# for child in node.get_node("Notes").get_children():
	# 	child.queue_free()
	# for child in node.get_node("Bars").get_children():
	# 	child.queue_free()

func _get_mid_partitures_size(song) -> int:
	var total_duration = float(song.initial_offset)
	for note in song.notes:
		total_duration += note.duration

	print("Total Duration: ", total_duration)
	song_total_duration = total_duration
	return max(ceil(total_duration / 240) - 1, 0)

func _turn_current_key_black():
	var i = 0
	for partiture in partiture_container.get_children():
		for note in partiture.get_node("Notes").get_children():
			if i == current_note_idx:
				note.become_black()
				return
			i += 1
