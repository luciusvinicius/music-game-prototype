extends Control

# --- Preloads --- #

const NOTE = preload("res://assets/imgs/partiture/note_white.png")
const PARTITURE_MID = preload("res://assets/imgs/partiture/partiture_mid.png")
const PARTITURE_END = preload("res://assets/imgs/partiture/partiture_end.png")


# --- Constants --- #
const SCROLL_SPEED = 50
@onready var note_gray = $ScrollContainer/HBoxContainer/Start/NoteGray



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	print(note_gray.position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
