extends CanvasLayer

signal on_resume_button_pressed

func _on_MainMenuButton_pressed():
	Network.on_disconnected_from_server()

func _on_ResumeButton_pressed():
	emit_signal("on_resume_button_pressed")
