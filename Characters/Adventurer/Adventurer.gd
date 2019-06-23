extends KinematicBody2D

const RUN_SPEED = 100
const SPRINT_SPEED = 150
const FLOOR = Vector2(0, -1)

const MAX_JUMP_HEIGHT = 6 * 16
const MIN_JUMP_HEIGHT = 2 * 16
const TIME_TO_JUMP_APEX = 0.45

var move_speed : float = RUN_SPEED
var gravity : float
var max_jump_velocity : float
var min_jump_velocity : float
var x_dir : int # direction in which player is facing in the x-axis

var is_grounded : bool = true
var is_sprinting : bool = false
var can_double_jump : bool = true
var is_double_jumping : bool = false
var is_attacking : bool = false
var attack_combo : int = 0
var health : int = 100

var velocity : Vector2 = Vector2(0, 0)

var net_id : int = 1

puppet var repl_position : Vector2 = Vector2()
puppet var repl_animation : String = "idle"
puppet var repl_scale_x : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	gravity = MAX_JUMP_HEIGHT / pow(TIME_TO_JUMP_APEX, 2)
	max_jump_velocity = -sqrt(2 * gravity * MAX_JUMP_HEIGHT)
	min_jump_velocity = -sqrt(2 * gravity * MIN_JUMP_HEIGHT)
	net_id = GameState.player_info.net_id
	
func _physics_process(delta):
	if is_network_master():
		direction_input()				# horizontal mvmt
		sprint_input()
		jump_input()					# jump
		acceleration_curve()			# simluate acceleration when moving
		attack_input()
		flip_sprite(x_dir)				# flips sprite when turning direction
		play_animation(x_dir)
		velocity.y += gravity * delta 	# gravity
		velocity = move_and_slide(velocity, FLOOR)	# godot's physics
		rset("repl_position", position)
	else:
		position = repl_position									# to replitcate current position
		$AnimationPlayer.current_animation = repl_animation 		# to replicate current animation
		$Sprite.scale.x = repl_scale_x 								# to replicate change in x direction
	
func direction_input():
	x_dir = 0
	if Input.is_action_pressed("ui_right"):
		x_dir += 1
	if Input.is_action_pressed("ui_left"):
		x_dir += -1
		
func sprint_input():
	# only resets sprint when on the floor, retain sprint speed when in air
	if is_on_floor():
		move_speed = RUN_SPEED
		is_sprinting = false
	if Input.is_action_pressed("ui_select") && is_on_floor():
		move_speed = SPRINT_SPEED
		is_sprinting = true
		
# Moves player according to this acceleration curve
func acceleration_curve():
	if !is_attacking:
		if is_on_floor():
			velocity.x = lerp(velocity.x, move_speed * x_dir, 0.2)
		else:
			velocity.x = lerp(velocity.x, move_speed * x_dir, 0.08)
	else:
		if is_on_floor():
			velocity.x = lerp(velocity.x, 0, 0.2)
		else:
			velocity.x = lerp(velocity.x, move_speed * x_dir, 0.01)

func attack_input():
	if Input.is_action_pressed("ui_focus_next") && !is_attacking:
		is_attacking = true

		if attack_combo == 0:
			$AnimationPlayer.current_animation = "attack1"
			rset("repl_animation", "attack1")		
			attack_combo = 1
		elif attack_combo == 1:
			$AnimationPlayer.current_animation = "attack2"
			rset("repl_animation", "attack2")
			attack_combo = 2
		elif attack_combo == 2:
			$AnimationPlayer.current_animation = "attack3"
			rset("repl_animation", "attack3")
			attack_combo = 0
	
func jump_input():
	# resets the double jump when landing
	if is_on_floor():
		can_double_jump = true
		is_double_jumping = false
	
	if Input.is_action_just_pressed("ui_up"):
		if !is_attacking:
			if !is_on_floor():
				if can_double_jump:
					can_double_jump = false
					is_double_jumping = true
					velocity.y = (min_jump_velocity + max_jump_velocity) / 2
			else:
				velocity.y = max_jump_velocity
	
	# variable jump height
	if Input.is_action_just_released("ui_up") && velocity.y < min_jump_velocity:
		velocity.y = min_jump_velocity
		
func flip_sprite(x_dir):
	if x_dir > 0:
		$Sprite.scale.x = 1
		rset("repl_scale_x", 1)
	elif x_dir < 0:
		$Sprite.scale.x = -1
		rset("repl_scale_x", -1)
		
func play_animation(x_dir):
	if is_on_floor():
		if !is_attacking:
			if x_dir == 0:
				$AnimationPlayer.current_animation = "idle"
				rset("repl_animation", "idle")		
			else:
				if is_sprinting:
					$AnimationPlayer.current_animation = "sprint"
					rset("repl_animation", "sprint")
				else:
					$AnimationPlayer.current_animation = "run"
					rset("repl_animation", "run")
	else:
		if !is_attacking:
			if velocity.y < 0:
				if is_double_jumping:
					$AnimationPlayer.current_animation = "double_jump"
					rset("repl_animation", "double_jump")
				else:
					$AnimationPlayer.current_animation = "jump"
					rset("repl_animation", "jump")
			if velocity.y > 0:
				$AnimationPlayer.current_animation = "fall"
				rset("repl_animation", "fall")

func _on_AnimationPlayer_animation_finished(attack1):
	is_attacking = false

func _on_PlayerHitBox_area_entered(area):
	# Check if its player's own sword
	if area != $Sprite.get_node("SwordHitBox"):
		# Check if its players colliding with other players
		if area.name != "PlayerHitBox":
			# OUR PLAYER GOT HIT
			if is_network_master():
				health -= 10
				print(health)
				$DamageAnimation.current_animation = "damage"
			# OTHER PLAYER GOT HIT
			else:
				$DamageAnimation.current_animation = "damage"
				

