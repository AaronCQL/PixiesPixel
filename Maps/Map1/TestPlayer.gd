extends KinematicBody2D

const SPEED = 100
const GRAVITY = 10
const JUMP_POWER = -250
const FLOOR = Vector2(0, -1)

var velo = Vector2()

func _physics_process(delta):
	if Input.is_action_pressed("ui_right"):
		velo.x = SPEED
	elif Input.is_action_pressed("ui_left"):
		velo.x = -SPEED
	else:
		velo.x = 0
		
	if Input.is_action_pressed("ui_up"):
		velo.y = JUMP_POWER
		
	velo.y += GRAVITY
	
	velo = move_and_slide(velo)