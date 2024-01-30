extends Node2D

## -- || Nodes || -- ##
@onready var speech_balloon = $SpeechBalloon
@onready var animation = $AnimatedSprite

## -- || Vars || -- ##
const PREVIOUS_SCORES_AMOUNT = 10
var previous_scores = []


func _ready():
	var timer = get_tree().create_timer(1)
	await timer.timeout
	speak(NpcDialogue.get_greeting())
	SignalManager.played_on_beat_score.connect(_on_beat_score)

func speak(text:String):
	animation.play("talking")
	speech_balloon.show()
	speech_balloon.display_dialogue(text)

func _on_speech_balloon_finished_speech():
	print("Finish balloon")
	animation.play("default")
	speech_balloon.hide()


func _on_beat_score(value):
	previous_scores.append(value)
	if previous_scores.size() > PREVIOUS_SCORES_AMOUNT:
		evaluate_score()

func evaluate_score():
	# Obtain the most common score in the previous scores
	var total_score = 0
	for score in previous_scores:
		total_score += score
	
	# Speak the dialogue corresponding to the most common score
	var dialogue = NpcDialogue.get_beat_score(total_score, previous_scores.size())

	print("Total score: " + str(total_score))
	speak(dialogue)
	previous_scores.clear()
