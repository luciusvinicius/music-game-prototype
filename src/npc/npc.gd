extends Node2D

@onready var speech_balloon = $SpeechBalloon
@onready var animation = $AnimatedSprite

func _ready():
	var timer = get_tree().create_timer(1)
	await timer.timeout
	speak(NpcDialogue.get_greeting())

func speak(text:String):
	animation.play("talking")
	speech_balloon.show()
	speech_balloon.display_dialogue(text)


func _on_speech_balloon_finished_speech():
	animation.play("default")
	speech_balloon.hide()
