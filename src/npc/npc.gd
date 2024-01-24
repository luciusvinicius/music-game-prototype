extends Node2D

@onready var speech_balloon = $SpeechBalloon
const SPEECH := "VERY SUSSY BAKA IS VERY SUSPICIOUS MAAAANKIND KNEW"


func _ready():
	var timer = get_tree().create_timer(1)
	await timer.timeout
	speak(SPEECH)

func speak(text:String):
	speech_balloon.show()
	speech_balloon.display_text(text)


func _on_speech_balloon_finished_speech():
	speech_balloon.hide()
