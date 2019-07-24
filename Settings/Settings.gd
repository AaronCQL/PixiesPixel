extends CanvasLayer

var audio_player

func _ready():
	$Panel.hide()
	Network.connect("on_exit_button_pressed", self, "_show_main_menu")
	audio_player = get_node("AudioStreamPlayer")

func _on_MusicToggle_toggled(button_pressed):
	if button_pressed == true:
		AudioServer.set_bus_mute(1, false)
	else:
		AudioServer.set_bus_mute(1, true)

func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(1, value)

func _on_SoundEffectsToggle_toggled(button_pressed):
	if button_pressed == true:
		AudioServer.set_bus_mute(2, false)
	else:
		AudioServer.set_bus_mute(2, true)

func _on_SoundEffectsSlider_value_changed(value):
	AudioServer.set_bus_volume_db(2, value)
			
func _on_BackButton_pressed():
	get_node("/root/MainMenu/NetworkPanel").show()
	$Panel.hide()
