extends Node

# Beats
signal beat_played
signal measure_played
signal update_measure(measure_value)
signal melodies_in_loop_changed(number)
signal bpm_updated(bpm_value)

# Keys
signal selected_instrument(instrument)
signal changed_sustain(value)
signal key_pressed(key_node)
