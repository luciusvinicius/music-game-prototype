extends Control

@onready var instruments = $PanelContainer/VBoxContainer/Instruments

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create Instruments buttons
	for instrument in Instruments.INSTRUMENTS:
		var instrument_button = Button.new()
		instrument_button.text = instrument.name
		instrument_button.pressed.connect(_on_instrument_button_pressed.bind(instrument.name)) # Add "beat.name" as an extra argument
		instruments.add_child(instrument_button)


func _on_instrument_button_pressed(instrument_name: String):
	var instrument = Instruments.get_instrument(instrument_name)
	SignalManager.selected_instrument.emit(instrument)


func _on_sustain_toggle_toggled(toggled_on):
	SignalManager.changed_sustain.emit(toggled_on)
