extends Control

@onready var beat = $Beat
@onready var bpm : Label = $PanelContainer/VBoxContainer/BPM

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_beat_1_pressed():
	beat.play(true)


func _on_bpm_slider_value_changed(value):
	beat.bpm = value
	bpm.text = "BPM: %d" % value
