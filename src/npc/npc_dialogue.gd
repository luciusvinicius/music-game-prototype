extends Node

## -- || Consts || --
const GREETINGS = [
	"Hello! Glad you are here!",
	"Hi! Ready to play some music?",
	"Hii! I hope you had a good day today!"
]

const PERFECT_BEAT_SCORE = [
	"Nicely done! You are very good at this!",
	"Wow! You are a natural!",
	"Amazing! You are a true musician!"
]

const GOOD_BEAT_SCORE = [
	"Good job! You are getting better!",
	"Nice! You are improving!",
	"Great! You are getting the hang of it!"
]

const BAD_BEAT_SCORE = [
	"Keep trying! You will get it!",
	"Almost there! Keep going!",
	"Practice makes perfect!"
]

## -- || Getters || --
func get_greeting():
	return GREETINGS.pick_random()

func get_perfect_beat_score():
	return PERFECT_BEAT_SCORE.pick_random()

func get_good_beat_score():
	return GOOD_BEAT_SCORE.pick_random()

func get_bad_beat_score():
	return BAD_BEAT_SCORE.pick_random()

func get_beat_score(total_score: int, previous_score_size: int):
	var PERFECT_SCORE = 4 * (previous_score_size - 1)
	var GOOD_SCORE = 2 * (previous_score_size - 1)
	if total_score >= PERFECT_SCORE:
		return get_perfect_beat_score()
	elif total_score >= GOOD_SCORE:
		return get_good_beat_score()
	else:
		return get_bad_beat_score()
