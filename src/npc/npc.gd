extends Node2D

## -- || Nodes || -- ##
@onready var speech_balloon = $SpeechBalloon
@onready var animation = $AnimatedSprite

## -- || Vars || -- ##
const PREVIOUS_SCORES_AMOUNT = 10
var previous_scores = []
var dialogue_queue = []
var is_speaking = false

func _ready():
	var timer = get_tree().create_timer(1)
	await timer.timeout
	speak(NpcDialogue.get_greeting())
	SignalManager.played_on_beat_score.connect(_on_beat_score)

func speak(text:String):
	dialogue_queue.append(text)
	_speak()

func _speak():
	if is_speaking: return # Ignore new added text if already is speaking
	is_speaking = true
	animation.play("talking")
	speech_balloon.show()
	speech_balloon.display_dialogue(dialogue_queue.pop_front())

func _on_speech_balloon_finished_speech():
	is_speaking = false
	speech_balloon.hide()
	if dialogue_queue.size() > 0:
		await get_tree().create_timer(1).timeout
		_speak()

func _on_speech_balloon_finished_typing():
	animation.play("default")
		
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


func challenge_player():
	# var dialogues = []
	dialogue_queue.append(NpcDialogue.get_song_challenge())
	dialogue_queue.append(NpcDialogue.get_metronome_help())
	_speak()
	#SignalManager.played_on_beat_score.disconnect(_on_beat_score)
	#SignalManager.played_on_beat_score.connect(_on_challenge_score) <-- not a ma ideia

func _on_song_trial_timer_timeout():
	challenge_player()


