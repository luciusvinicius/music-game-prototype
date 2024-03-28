extends Button

# func _ready():
# 	set_toggle_mode(true)

func _unhandled_input(event):
	if event.is_action_pressed("Select") and is_hovered():
		button_pressed = true
		pressed.emit()
	elif event.is_action_released("Select") and button_pressed:
		button_pressed = false
		pass
