extends Node2D

signal key_pressed(index)

## -- || Nodes || --
@onready var pressed_sprite : Sprite2D = $PressedSprite
@onready var rect : ColorRect = $Rect
@onready var key_sound : AudioStreamPlayer = $KeySound
@onready var minimum_click_timer : Timer = $MinimumClickTimer

### -- || Vars || --

## -- || Exports || --
@export var pressed_sprite_texture : Texture2D
@export var sustain := true
@export_range(0, 11) var pitch := 0.01:
	set(new_value):
		key_sound.pitch_scale = new_value

## -- || Consts || --
# Used to change the touch_area collision accordingly to the note
const NORMAL_Y_SIZE = 15.0
const NORMAL_Y_POSITION = -6.0
const SHARP_Y_OFFSET = -2.0
const SHARP_Y_SIZE = 8.5
const COLLISION_X_SIZE = 3.75
const COLLISION_X_POSITION = -13.25
const COLLISION_X_OFFSET = 2.0


## -- || Logic || --
var mouse_hovered := false
var click_time := 0.0
var octave := 0

@onready var automatic_pressed_sprite_texture : Texture2D = load("res://assets/imgs/Notes/" \
 + name + "-auto.png") # Texture for presses not made by the player

@onready var tutorial_pressed_sprite_texture : Texture2D = load("res://assets/imgs/Notes/" \
 + name + "-orange.png") # Texture for presses not made by the tutorial

### -- || Main Code || --

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed_sprite.texture = pressed_sprite_texture
	
	# Connect to change instrument signal
	SignalManager.selected_instrument.connect(_update_instrument)
	SignalManager.changed_sustain.connect(_update_sustain)
	
	# Update collision size
	var is_sharp = name.contains("#")
	var selected_offset = NORMAL_Y_POSITION + SHARP_Y_OFFSET if is_sharp else NORMAL_Y_POSITION
	var selected_size = SHARP_Y_SIZE if is_sharp else NORMAL_Y_SIZE
	rect.size = Vector2(COLLISION_X_SIZE, selected_size) * scale.x
	
	# Update collision position
	var note_idx = Consts.get_note_idx(name)
	var position_x = note_idx * COLLISION_X_OFFSET + COLLISION_X_POSITION
	if note_idx == 5: # Add offset to blacknote that doesn't exist
		position_x += COLLISION_X_OFFSET
	elif note_idx >= 6:
		position_x += COLLISION_X_OFFSET / 1.0
	
	rect.position.x = position_x
	rect.position.y = selected_offset
		

## -- || Presses/Releases || --
func press_key(ignore_signal := false):
	minimum_click_timer.stop()
	key_pressed.emit(get_index())
	pressed_sprite.show()
	click_time = 0.0
	key_sound.play()
	
	# Used in automatic note press/release (note loops for instance)
	if not ignore_signal: 
		SignalManager.key_pressed.emit(self)
		
		# Update to red key
		if pressed_sprite.texture != pressed_sprite_texture:
			pressed_sprite.texture = pressed_sprite_texture

func automatic_press_key():
	# Update pressed color
	if pressed_sprite.texture != automatic_pressed_sprite_texture:
		pressed_sprite.texture = automatic_pressed_sprite_texture
	
	press_key(true)

func tutorial_press_key():
	# Update pressed color
	if pressed_sprite.texture != tutorial_pressed_sprite_texture:
		pressed_sprite.texture = tutorial_pressed_sprite_texture
	
	pressed_sprite.show()

func release_key(ignore_signal := false):
	if not ignore_signal and minimum_click_timer.is_stopped():
		minimum_click_timer.start()
		#print(minimum_click_timer)
		await minimum_click_timer.timeout
	pressed_sprite.hide()
	if not sustain: key_sound.stop()
	
	# Used in automatic note press/release (note loops for instance)
	if not ignore_signal: SignalManager.key_released.emit(self)

# Update audio ----------------------
func _update_instrument(instrument):
	key_sound.stream = instrument.stream

func _update_sustain(value):
	sustain = value

# Input Detection --------------------
func _unhandled_input(event):
	if event.is_action_pressed("Select") and mouse_hovered:
		press_key()
	elif event.is_action_released("Select") and pressed_sprite.texture == pressed_sprite_texture:
		release_key()

func _on_rect_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				press_key()
			elif pressed_sprite.texture == pressed_sprite_texture:
				release_key()

func _on_rect_mouse_entered():
	mouse_hovered = true

func _on_rect_mouse_exited():
	mouse_hovered = false
