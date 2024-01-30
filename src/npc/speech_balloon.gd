extends MarginContainer

@onready var label = $MarginContainer2/Label
@onready var display_timer = $LetterDisplayTimer
@onready var finish_timer = $FinishTimer

signal finished_speech
signal finished_typing

const MAX_WIDTH = 200
const LETTER_TIME = 0.03
const SPACE_TIME = 0.06
const PUNCTUATION_TIME = 0.2
const FINISH_TIME_MULTIPLIER = 0.075
const ORIGINAL_Y_POSITION = -160
var reseted := true

var text := ""
var letter_idx := 0

func _process(_delta):
	position.x = -size.x / 2
	position.y = ORIGINAL_Y_POSITION - size.y / 2
	size.x = MAX_WIDTH


func display_dialogue(display_text:String):
	_reset_talk() # Reset if already talking something
	text = display_text
	label.text = text
	
	if size.x >= MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	label.text = ""
	reseted = false
	display_timer.stop()
	_display_next_letter()

func _display_next_letter():
	var ch = text[letter_idx]
	label.text += ch
	letter_idx += 1
	if letter_idx >= text.length():
		finished_typing.emit()
		finish_timer.start(FINISH_TIME_MULTIPLIER * text.length())
		return
	
	match ch:
		"!", ".", "?", ",":
			display_timer.start(PUNCTUATION_TIME)
		" ":
			display_timer.start(SPACE_TIME)
		_:
			display_timer.start(LETTER_TIME)

func _reset_talk():
	size.y= 0
	letter_idx = 0
	reseted = true


func _on_letter_display_timer_timeout():
	_display_next_letter()


func _on_finish_timer_timeout():
	if not reseted:
		finished_speech.emit()
	_reset_talk()

