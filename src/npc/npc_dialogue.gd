extends Node

## -- || Consts || --
const GREETINGS = [
	"Hello! Glad you are here!",
	"Hi! Ready to play some music?",
	"Hii! I hope you had a good day today!"
]


## -- || Getters || --
func get_greeting():
	return GREETINGS.pick_random()
