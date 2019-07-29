extends CanvasLayer

var audio_player

var config : ConfigFile
var is_music_mute : bool
var music_volume : float
var is_sound_effects_mute : bool
var sound_effects_volume : float
var is_fullscreen : bool

func _ready():
	$Panel.hide()
	audio_player = get_node("AudioStreamPlayer")
	init_config()
	$AudioStreamPlayer.playing = true

func init_config():
	config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK: # if not, something went wrong with the file loading
		# Look for the display/width pair, and default to 1024 if missing
		music_volume = config.get_value("music", "volume", 0)
		AudioServer.set_bus_volume_db(1, music_volume)
		$Panel/MusicSlider.value = music_volume
		
		sound_effects_volume = config.get_value("sound_effects", "volume", 0)
		AudioServer.set_bus_volume_db(2, sound_effects_volume)
		$Panel/SoundEffectsSlider.value = sound_effects_volume
		
		is_music_mute = config.get_value("music", "mute", false)
		AudioServer.set_bus_mute(1, is_music_mute)
		$Panel/MusicToggle.pressed = !is_music_mute
		
		is_sound_effects_mute = config.get_value("sound_effects", "mute", false)
		AudioServer.set_bus_mute(2, is_sound_effects_mute)
		$Panel/SoundEffectsToggle.pressed = !is_sound_effects_mute
		
		is_fullscreen = config.get_value("gameplay", "fullscreen", false)
		OS.window_fullscreen = is_fullscreen
		$Panel/FullscreenButton.pressed = is_fullscreen
	
func _on_MusicToggle_toggled(button_pressed):
	if button_pressed == true:
		AudioServer.set_bus_mute(1, false)
		is_music_mute = false
	else:
		AudioServer.set_bus_mute(1, true)
		is_music_mute = true

func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(1, value)
	music_volume = value

func _on_SoundEffectsToggle_toggled(button_pressed):
	if button_pressed == true:
		AudioServer.set_bus_mute(2, false)
		is_sound_effects_mute = false
	else:
		AudioServer.set_bus_mute(2, true)
		is_sound_effects_mute = true

func _on_SoundEffectsSlider_value_changed(value):
	AudioServer.set_bus_volume_db(2, value)
	sound_effects_volume = value

func _on_FullscreenButton_toggled(button_pressed):
	if button_pressed == true:
		OS.window_fullscreen = true
		is_fullscreen = true
	else:
		OS.window_fullscreen = false
		is_fullscreen = false
		
func _on_BackButton_pressed():
	config.set_value("music", "mute", is_music_mute)
	config.set_value("music", "volume", music_volume)
	config.set_value("sound_effects", "mute", is_sound_effects_mute)
	config.set_value("sound_effects", "volume", sound_effects_volume)
	config.set_value("gameplay", "fullscreen", is_fullscreen)
	config.save("user://settings.cfg")
	$Panel.hide()
	if !get_node("/root").has_node("Map"):
		get_node("/root/MainMenu/NetworkPanel").show()

