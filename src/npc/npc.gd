extends Node2D

## -- || Nodes || -- ##
@onready var speech_balloon = $SpeechBalloon
@onready var animation = $AnimatedSprite

## -- || Vars || -- ##
const PREVIOUS_SCORES_AMOUNT = 10
var previous_scores = []
var tutorial_total_score = 0
var dialogue_queue = []
var is_speaking = false

## TODO: Some of those functions should be moved to another manager class (such as the tutorial starter, etc...)

func _ready():
	var timer = get_tree().create_timer(1)
	await timer.timeout
	speak(NpcDialogue.get_greeting())
	SignalManager.played_on_beat_score.connect(_on_beat_score)
	SignalManager.demo_song_played.connect(_on_song_demo_played)
	SignalManager.tutorial_key_pressed_score.connect(_on_tutorial_score)
	SignalManager.tutorial_ended.connect(_on_tutorial_end)

func speak(text:String):
	dialogue_queue.append(text)
	_speak()

func _speak():
	if is_speaking: return # Ignore new added text if already is speaking
	is_speaking = true
	animation.play("talking")
	speech_balloon.show()
	speech_balloon.display_dialogue(dialogue_queue.pop_front())

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
	SignalManager.unlock_next_song.emit(Songs.get_next_song())
	#SignalManager.played_on_beat_score.disconnect(_on_beat_score)
	#SignalManager.played_on_beat_score.connect(_on_challenge_score) <-- not a ma ideia



## -- || Signals || -- ##

func _on_speech_balloon_finished_typing():
	animation.play("default")

func _on_speech_balloon_finished_speech():
	is_speaking = false
	speech_balloon.hide()
	if dialogue_queue.size() > 0:
		await get_tree().create_timer(1).timeout
		_speak()
	
func _on_beat_score(value):
	previous_scores.append(value)
	if previous_scores.size() > PREVIOUS_SCORES_AMOUNT:
		evaluate_score()

func _on_song_trial_timer_timeout():
	challenge_player()

func _on_song_demo_played(song):
	speak(NpcDialogue.get_your_turn())
	tutorial_total_score = 0
	await get_tree().create_timer(1).timeout
	SignalManager.start_tutorial.emit(song)

func _on_tutorial_score(score):
	tutorial_total_score += score

func _on_tutorial_end(song):
	if not song: return
	var n_notes = song.notes.size()
	var percentage = tutorial_total_score / (n_notes * 200) # 200 is the max score per note
	print("Percentage: " + str(percentage))
	speak(NpcDialogue.get_tutorial_score(percentage))


func _on_fur_elise_timer_timeout():
	Songs.increase_song_level()
	challenge_player()
