extends Control

# --- Preloads --- #

# Notes
const HALF = preload("res://assets/imgs/partiture/notes/half2.png")
const QUARTER = preload("res://assets/imgs/partiture/notes/quarter2.png")
const EIGHTH = preload("res://assets/imgs/partiture/notes/eighth.png")

# Sheet
const PARTITURE_MID = preload("res://assets/imgs/partiture/partiture_mid_transparent.png")

# --- Nodes --- #
@onready var positions = $Positions
@onready var partiture_container = $ScrollContainer/PartitureContainer
@onready var scroll_container = $ScrollContainer

# --- Constants --- #
const SCROLL_SPEED_RATIO = 3
const NOTE_SPAWN_OFFSET_Y = 4
const NOTE_SPAWN_OFFSET_X = 8 * 5
const NOTE_MINIMUM_SIZE = Vector2(32, 54)
const PARTITURE_MINIMUM_SIZE = Vector2(196, 128)
const PARTITURE_SCROLL_OFFSET = 90
const SCROLL_LOOK_AHEAD_OFFSET = 0

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

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.play_note_on_keyboard.connect(create_note)
	SignalManager.demo_song_started.connect(load_song_partiture)

# func _process(delta):
# 	# if fisrt_note:
# 	# 	return
# 	scroll_container.scroll_horizontal = round(scroll_value)
# 	# print(scroll_value)

func load_song_partiture(song):
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
		partiture_container.move_child(partiture_mid, -3) # Add it to last, except the "partiture_end"

func create_demo_note(key):
	create_note(key, Colors.GRAY)


func create_note(key, color = Colors.BLACK):

	if fisrt_note:
		fisrt_note = false

	var note_node = TextureRect.new()
	note_node.texture = note_type2texture[Consts.NOTES_DURATION2NAME[key.duration]]
	note_node.custom_minimum_size = NOTE_MINIMUM_SIZE
	note_node.self_modulate = color

	## Spawn in correct position
	var octave_idx = key.note / 12 # Not used yet
	var note_idx = key.note % 12
	var note_order = Consts.NOTES_ORDER[note_idx]
	var position_marker = positions.get_child(Consts.NOTES_REGULAR_ORDER[note_order])
	
	# Get partiture
	var partiture_idx = total_duration_played / 240 + 1
	var partiture = partiture_container.get_child(partiture_idx)

	# Get X position
	var x_offset = (x_distance_traveled / (Songs.DURATION_PER_SHEET / 4)) * NOTE_SPAWN_OFFSET_X
	var y_offset = NOTE_SPAWN_OFFSET_Y - (octave_idx * 8 * 7)
	note_node.position = position_marker.position + Vector2(x_offset, y_offset)

	# Flip note
	if octave_idx > 0:
		note_node.flip_v = true
		note_node.position.y += 8 * 4 + NOTE_SPAWN_OFFSET_Y

	partiture.add_child(note_node)

	# Update total duration played
	total_duration_played += key.duration

	x_distance_traveled += key.duration
	if x_distance_traveled >= Songs.DURATION_PER_SHEET:
		x_distance_traveled = 0
	
	# Animate scroll value
	var scroll_distance 
	if total_duration_played >= song_total_duration:
		scroll_distance = 2 * scroll_container.size.x
	else:
		scroll_distance = float(total_duration_played) / song_total_duration * scroll_container.size.x + SCROLL_LOOK_AHEAD_OFFSET
		scroll_distance += total_duration_played / Songs.DURATION_PER_SHEET * PARTITURE_SCROLL_OFFSET # Add partiture size offset
	
	var scroll_time = float(key.duration) / Songs.DURATION_PER_SHEET * SCROLL_SPEED_RATIO
	var tween_scroll = get_tree().create_tween()
	tween_scroll.tween_property(scroll_container, "scroll_horizontal", scroll_distance, scroll_time)



# --- Other Functions --- #
func _remove_notes(node):
	for child in node.get_children():
		child.queue_free()

func _get_mid_partitures_size(song) -> int:
	var total_duration = float(song.initial_offset)
	for note in song.notes:
		total_duration += note.duration

	print("Total Duration: ", total_duration)
	song_total_duration = total_duration
	return max(ceil(total_duration / 240) - 1, 0)
