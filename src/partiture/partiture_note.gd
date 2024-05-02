class_name PartitureNote

extends TextureRect

## --- Nodes --- ##
@onready var sharp : Label = $Sharp
@onready var bar = $BarMarker
@onready var sharp_bar = $SharpBarMarker
@onready var stem = $Stem
@onready var stem_marker = $StemMarker
@onready var reverted_stem_marker = $RevertedStemMarker

## --- Consts --- ##
const NOTE_MINIMUM_SIZE = Vector2(32, 54)
const NOTE_SPAWN_OFFSET_Y = 4
const NOTE_SHARP_OFFSET_X = 8
const REVERSED_SHARP_OFFSET_Y = -32

# Notes
const HALF = preload("res://assets/imgs/partiture/notes/half2.png")
const HALF_REVERTED = preload("res://assets/imgs/partiture/notes/half2-reverted.png")
const QUARTER_NO_STEM = preload("res://assets/imgs/partiture/notes/quarter2-nostem.png")
const QUARTER_REVERTED_NO_STEM = preload("res://assets/imgs/partiture/notes/quarter2-reverted-nostem.png")
const QUARTER = preload("res://assets/imgs/partiture/notes/quarter2.png")
const QUARTER_REVERTED = preload("res://assets/imgs/partiture/notes/quarter2-reverted.png")
const EIGHTH = preload("res://assets/imgs/partiture/notes/eighth.png")
const EIGHTH_REVERTED = preload("res://assets/imgs/partiture/notes/eighth-reverted.png")

var key
var texture_name
var note_type2texture = {
	"half": HALF,
	"half-reverted": HALF_REVERTED,
	"quarter": QUARTER,
	"quarter-reverted": QUARTER_REVERTED,
	"quarter-no-stem": QUARTER_NO_STEM,
	"quarter-no-stem-reverted": QUARTER_REVERTED_NO_STEM,
	"eighth": EIGHTH,
	"eighth-reverted": EIGHTH_REVERTED
}


## --- Functions --- ##

func initiate(note_key, color):
	key = note_key

	texture_name = Consts.NOTES_DURATION2NAME[key.duration]

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
	_change_color(Colors.GRAY_TRANSPARENT)

func become_black():
	_change_color(Colors.BLACK)

func _change_color(color):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate", color, 1.0)
	var sharp_tween = get_tree().create_tween()
	sharp_tween.tween_property(sharp, "self_modulate", color, 1.0)
	var stem_tween = get_tree().create_tween()
	stem_tween.tween_property(stem, "self_modulate", color, 1.0)

func become_group_texture():
	texture_name = "quarter-no-stem"
	stem.show()
	stem.rotation_degrees = 180
	stem.position = stem_marker.position
	stem.self_modulate = self_modulate
	if is_reverted():
		texture_name += "-reverted"
		stem.rotation_degrees = 0
		stem.position = reverted_stem_marker.position
	
	texture = note_type2texture[texture_name]

func revert():
	if "reverted" not in texture_name:
		texture_name += "-reverted"
		texture = note_type2texture[texture_name]
		position.y += 8 * 4 + NOTE_SPAWN_OFFSET_Y
		sharp.position.y += REVERSED_SHARP_OFFSET_Y
		stem.rotation_degrees = 0
		stem.position = reverted_stem_marker.position

func update_stem_size(rectangle):
	var y_diff = rectangle.global_position.y - stem.global_position.y
	stem.size.y = abs(y_diff)

# --- Getters --- #
func get_bar_position():
	var bar_position = sharp_bar.position if is_reverted() else bar.position
	return position + bar_position

# --- Boolean Functions --- #
func is_reverted():
	return key.note / 13 > 0

func is_reverted_texture():
	return "reverted" in texture_name

func is_sharp():
	var note = Consts.NOTES_ORDER[key.note % 12]
	return "#" in note

func is_half():
	return Consts.NOTES_DURATION2NAME[key.duration] == "half"

func is_quarter():
	return Consts.NOTES_DURATION2NAME[key.duration] == "quarter"

func is_eighth():
	return Consts.NOTES_DURATION2NAME[key.duration] == "eighth"


