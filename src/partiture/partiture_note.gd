class_name PartitureNote

extends TextureRect

## --- Nodes --- ##
@onready var sharp : Label = $Sharp
@onready var bar = $Bar
@onready var sharp_bar = $SharpBar

## --- Consts --- ##
const NOTE_MINIMUM_SIZE = Vector2(32, 54)
const NOTE_SPAWN_OFFSET_Y = 4
const NOTE_SHARP_OFFSET_X = 8
const REVERSED_SHARP_OFFSET_Y = -32

# Notes
const HALF = preload("res://assets/imgs/partiture/notes/half2.png")
const HALF_REVERTED = preload("res://assets/imgs/partiture/notes/half2-reverted.png")
const QUARTER = preload("res://assets/imgs/partiture/notes/quarter2.png")
const QUARTER_REVERTED = preload("res://assets/imgs/partiture/notes/quarter2-reverted.png")
const EIGHTH = preload("res://assets/imgs/partiture/notes/eighth.png")
const EIGHTH_REVERTED = preload("res://assets/imgs/partiture/notes/eighth-reverted.png")

var key

var note_type2texture = {
	"half": HALF,
	"half-reverted": HALF_REVERTED,
	"quarter": QUARTER,
	"quarter-reverted": QUARTER_REVERTED,
	"eighth": EIGHTH,
	"eighth-reverted": EIGHTH_REVERTED
}


## --- Functions --- ##

func initiate(note_key, color):
	key = note_key

	var texture_name = Consts.NOTES_DURATION2NAME[key.duration]

	if is_reverted():
		texture_name += "-reverted"

	texture = note_type2texture[texture_name]
	custom_minimum_size = NOTE_MINIMUM_SIZE
	self_modulate = color

func _ready():
	sharp.self_modulate = self_modulate
	set_deferred("size", NOTE_MINIMUM_SIZE)
	if is_reverted():
		position.y += 8 * 4 + NOTE_SPAWN_OFFSET_Y
		sharp.position.y += REVERSED_SHARP_OFFSET_Y
	if is_sharp():
		sharp.show()
		position.x += NOTE_SHARP_OFFSET_X
	

func become_transparent():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate", Colors.GRAY_TRANSPARENT, 1.0)
	var sharp_tween = get_tree().create_tween()
	sharp_tween.tween_property(sharp, "self_modulate", Colors.GRAY_TRANSPARENT, 1.0)


func become_quarter_texture():
	var texture_name = "quarter"
	if is_reverted():
		texture_name += "-reverted"
	texture = note_type2texture[texture_name]

# --- Getters --- #
func get_bar_position():
	var bar_position = sharp_bar.position if is_reverted() else bar.position
	return position + bar_position

# --- Boolean Functions --- #
func is_reverted():
	return key.note / 12 > 0

func is_sharp():
	var note = Consts.NOTES_ORDER[key.note % 12]
	return "#" in note

func is_half():
	return Consts.NOTES_DURATION2NAME[key.duration] == "half"

func is_quarter():
	return Consts.NOTES_DURATION2NAME[key.duration] == "quarter"

func is_eighth():
	return Consts.NOTES_DURATION2NAME[key.duration] == "eighth"


