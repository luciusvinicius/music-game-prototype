extends Node

# Beats
signal beat_played
signal measure_played
signal melodies_in_loop_changed(number)

# Keys
signal selected_instrument(instrument)
signal changed_sustain(value)
signal key_pressed(key_node)
