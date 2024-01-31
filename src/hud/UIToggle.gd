extends CheckButton

var selected := true

func _ready():
	set_toggle_mode(true)

func _unhandled_input(event):
	if event.is_action_pressed("Select") and is_hovered():
		selected = !selected
		button_pressed = selected
		toggled.emit(selected)
