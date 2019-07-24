extends CanvasLayer

var audio_player

func _ready():
	$Panel.hide()
	Network.connect("on_exit_button_pressed", self, "_show_main_menu")
	audio_player = get_node("AudioStreamPlayer")

func _on_CheckButton_toggled(button_pressed):
	if button_pressed == true:
		audio_player.play()
	else:
		audio_player.stop()

func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(0, value)

func _on_BackButton_pressed():
	get_node("/root/MainMenu/NetworkPanel").show()
	$Panel.hide()
