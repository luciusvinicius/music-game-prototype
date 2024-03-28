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
signal key_released(key_node)
signal played_on_beat_score(value) # 0 = bad, 1 = good, 2 = perfect

# Songs
signal play_note_on_keyboard(note) # Used to play automatic songs
signal play_tutorial_note_on_keyboard(note)
signal release_note_on_keyboard(note)
signal unlock_next_song(song_name)
signal demo_song_played(song_name)
signal start_tutorial(song_name)
signal tutorial_key_pressed_score(score) 
signal tutorial_ended(song)

# Tutorial Remake
signal reset_beat()
