extends CanvasLayer

signal on_resume_button_pressed

func _ready():
	$Panel.hide()

func _on_MainMenuButton_pressed():
	Network.exit_to_main_menu()

func _on_ResumeButton_pressed():
	emit_signal("on_resume_button_pressed")

func _on_SettingsButton_pressed():
	emit_signal("on_resume_button_pressed")
	get_node("/root/Settings/Panel").show()
