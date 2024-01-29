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
	var most_common_score_dict = {}

	for score in previous_scores:
		if most_common_score_dict.has(score):
			most_common_score_dict[score] += 1
		else:
			most_common_score_dict[score] = 1

	var most_common_score = ""
	for score in most_common_score_dict.keys():
		if not most_common_score_dict.has(most_common_score):
			most_common_score = score
			continue
		if most_common_score_dict[score] >= most_common_score_dict[most_common_score]:
			most_common_score = score
	
	# Speak the dialogue corresponding to the most common score
	var dialogue
	match most_common_score:
		"bad":
			dialogue = NpcDialogue.get_bad_beat_score()
		"good":
			dialogue = NpcDialogue.get_good_beat_score()
		"perfect":
			dialogue = NpcDialogue.get_perfect_beat_score()

	speak(dialogue)
	previous_scores.clear()
