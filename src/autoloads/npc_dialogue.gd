extends Node

## -- || Consts || --
const GREETINGS = [
	"Hello! Glad you are here!",
	"Hi! Ready to play some music?",
	"Hii! I hope you had a good day today!"
]


# On Beat Scores

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


# Challenges

const CHALLENGE_SONG_TEMPLATE = [
	"Hmm, I wonder if you can you play %s.",
	"Let's see if you can play %s.",
]

const METRONOME_HELP = [
	"Remember that you can use the Metronome to help you!",
	"You can always use the Metronome to help you!",
	"Try using the Metronome Beat to help you!"
]

const YOUR_TURN = [
	"Your turn now!",
	"Let's see what you can do!",
	"Now! Show me what you got!"
]


# Tutorial Scores

const PERFECT_TUTORIAL_SCORE = [
	"Wow, you really surprised me! Great job!",
	"You played that perfectly! Amazing!",
	"I knew you could do it!"
]

const GOOD_TUTORIAL_SCORE = [
	"Nice job! Some more practice and you will be a pro!",
	"Great! Some details and you will nail it!",
]

const BAD_TUTORIAL_SCORE = [
	"Practice leads to perfection! Keep going!",
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


# Challenges

func get_song_challenge():
	var choosen_song = Songs.get_challenge_song()
	return CHALLENGE_SONG_TEMPLATE.pick_random() % choosen_song.name

func get_metronome_help():
	return METRONOME_HELP.pick_random()

func get_your_turn():
	return YOUR_TURN.pick_random()

func get_tutorial_score(score_percentage: float):
	const PERFECT = 0.8
	const GOOD = 0.6
	if score_percentage >= PERFECT:
		return PERFECT_TUTORIAL_SCORE.pick_random()
	elif score_percentage >= GOOD:
		return GOOD_TUTORIAL_SCORE.pick_random()
	else:
		return BAD_TUTORIAL_SCORE.pick_random()
