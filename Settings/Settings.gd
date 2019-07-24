extends CanvasLayer

var audio_player

func _ready():
	audio_player = get_node("AudioStreamPlayer2D")

func _on_CheckButton_toggled(button_pressed):
	if button_pressed == true:
		audio_player.play()
	else:
		audio_player.stop()


func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(0, value)
	
