extends CanvasLayer

func _process(delta):
	if Input.is_action_pressed("ui_right"):
		$Panel/Arrows.frame = 2
	elif Input.is_action_pressed("ui_left"):
		$Panel/Arrows.frame = 1
	else:
		$Panel/Arrows.frame = 0