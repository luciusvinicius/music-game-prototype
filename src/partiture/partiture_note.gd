class_name PartitureNote

extends TextureRect

## --- Nodes --- ##
@onready var sharp = $Sharp

## --- Consts --- ##
const NOTE_MINIMUM_SIZE = Vector2(32, 54)
const NOTE_SPAWN_OFFSET_Y = 4

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

func _init(note_key, color):
	key = note_key

	var texture_name = Consts.NOTES_DURATION2NAME[key.duration]

	if is_reverted():
		texture_name += "-reverted"

	texture = note_type2texture[texture_name]
	custom_minimum_size = NOTE_MINIMUM_SIZE
	self_modulate = color

func _ready():
	if is_reverted():
		position.y += 8 * 4 + NOTE_SPAWN_OFFSET_Y
	
#func _ready():
	#var note_idx = key.note % 12
	#var note_order = Consts.NOTES_ORDER[note_idx]
	#print("Children:", get_children())
	#print("Sharp: ", $Sharp)
	#if "#" in note_order:
		#print("Sharp: ", sharp)
		#sharp.show()

func become_transparent():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate", Colors.GRAY_TRANSPARENT, 1.0)



func is_reverted():
	return key.note / 12 > 0
