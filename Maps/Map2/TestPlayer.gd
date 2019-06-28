extends KinematicBody2D

const SPEED = 80
const GRAVITY = 9
const JUMP_POWER = -265
const FLOOR = Vector2(0, -1)


var velocity = Vector2()
var on_ground = false
var is_attacking = false
var is_dead = false

func _physics_process(delta):
	
	if is_dead == false:
		
		if Input.is_action_pressed("ui_right"):
			if is_attacking == false || is_on_floor() == false:
				velocity.x = SPEED


		
		elif Input.is_action_pressed("ui_left"):
			if is_attacking == false || is_on_floor() == false:
				velocity.x = -SPEED
					
		else:
			velocity.x = 0

			
		
		if Input.is_action_pressed("ui_up"):
			if is_attacking == false:
				if on_ground == true:
					velocity.y = JUMP_POWER
					on_ground = false
				
			
		velocity.y += GRAVITY
		
		if is_on_floor():
			if on_ground == false:
				is_attacking = false
			on_ground = true
		else: 
			if is_attacking == false:		
				on_ground = false	
		
		velocity = move_and_slide(velocity, FLOOR)
		
		

