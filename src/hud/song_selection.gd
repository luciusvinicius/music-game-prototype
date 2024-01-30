extends Control

@onready var song_player = $SongPlayer
@onready var songs = $PanelContainer/VBoxContainer/Songs

func _ready():
	SignalManager.unlock_next_song.connect(unlock_song)

func play_song(song_name:String):
	song_player.play_song(song_name)

func unlock_song(song_name:String):
	var songButton = Button.new()
	songButton.text = song_name
	songButton.pressed.connect(play_song.bind(song_name))
	songs.add_child(songButton)

	
