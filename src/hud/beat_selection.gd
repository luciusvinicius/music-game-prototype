extends Control

@onready var beat_manager = $Beat
@onready var bpm : Label = $PanelContainer/VBoxContainer/BPM
@onready var beats = $PanelContainer/VBoxContainer/Beats
@onready var melodies_loop = $PanelContainer/VBoxContainer/MelodiesLoop

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create Beats buttons
	for beat in Beats.BEATS:
		var beat_button = Button.new()
		beat_button.text = beat.name
		beat_button.pressed.connect(_on_beat_button_pressed.bind(beat.name)) # Add "beat.name" as an extra argument
		beats.add_child(beat_button)

func _on_beat_button_pressed(beat_name: String):
	beat_manager.play(beat_name)

func _on_beat_1_pressed():
	beat_manager.play("")

func _on_bpm_slider_value_changed(value):
	beat_manager.bpm = value
	bpm.text = "BPM: %d" % value

func _on_no_beat_pressed():
	beat_manager.stop()

func _on_melodies_loop_slide_value_changed(value):
	SignalManager.melodies_in_loop_changed.emit(value)
	melodies_loop.text = "Melodies Looped: %d" % value
