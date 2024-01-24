extends MarginContainer

@onready var label = $MarginContainer2/Label
@onready var display_timer = $LetterDisplayTimer
@onready var finish_timer = $FinishTimer

signal finished_speech

const MAX_WIDTH = 256
const LETTER_TIME = 0.03
const SPACE_TIME = 0.06
const PUNCTUATION_TIME = 0.2
const FINISH_TIME_MULTIPLIER = 0.075

var text := ""
var letter_idx := 0

func display_text(display_text:String):
	text = display_text
	label.text = text
	
	# Setup balloon size for whole text
	await resized
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized # wait for x
		await resized # wait for y
		custom_minimum_size.y = size.y
	
	#position.x -= size.x / 2
	#position.y -= size.y + 24
	
	label.text = ""
	_display_next_letter()

func _display_next_letter():
	var char = text[letter_idx]
	label.text += char
	letter_idx += 1
	if letter_idx >= text.length():
		finish_timer.start(FINISH_TIME_MULTIPLIER * text.length())
		return
	
	match char:
		"!", ".", "?", ",":
			display_timer.start(PUNCTUATION_TIME)
		" ":
			display_timer.start(SPACE_TIME)
		_:
			display_timer.start(LETTER_TIME)
	

func _on_letter_display_timer_timeout():
	_display_next_letter()


func _on_finish_timer_timeout():
	finished_speech.emit()
