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
var x_dir # direction in which player is facing in the x-axis

var is_grounded : bool = true
var is_sprinting : bool = false
var can_double_jump : bool = true
var is_double_jumping : bool = false
var is_attacking : bool = false
var attack_combo : int = 0

var velocity : Vector2 = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	gravity = MAX_JUMP_HEIGHT / pow(TIME_TO_JUMP_APEX, 2)
	max_jump_velocity = -sqrt(2 * gravity * MAX_JUMP_HEIGHT)
	min_jump_velocity = -sqrt(2 * gravity * MIN_JUMP_HEIGHT)

func _physics_process(delta):
	direction_input()				# horizontal mvmt
	sprint_input()					# sprint
	jump_input()					# jump	
	acceleration_curve()				# simluate acceleration when moving
	attack_input()					# attack
	on_death()					# handles death	
	flip_sprite(x_dir)				# flips sprite when turning direction
	play_animation(x_dir)				# handles animations
	better_camera()					# camera
	velocity.y += gravity * delta 			# gravity
	velocity = move_and_slide(velocity, FLOOR)	# godot's physics
	
	# DEBUGGING
	test_HUD()
	
func direction_input():
	x_dir = 0
	if Input.is_action_pressed("ui_right"):
		x_dir += 1
	if Input.is_action_pressed("ui_left"):
		x_dir += -1
		
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
			
func sprint_input():
	# only resets sprint when on the floor, retain sprint speed when in air
	if is_on_floor():
		move_speed = RUN_SPEED
		is_sprinting = false
	if Input.is_action_pressed("ui_select") && is_on_floor():
		move_speed = SPRINT_SPEED
		is_sprinting = true

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

func on_death():
	if ($Position2D.global_position.y > 500):
		get_tree().change_scene("World.tscn")

func flip_sprite(x_dir):
	if x_dir > 0:
		$AnimatedSprite.flip_h = false
	elif x_dir < 0:
		$AnimatedSprite.flip_h = true
		
func play_animation(x_dir):
	if is_on_floor():
		if !is_attacking:
			if x_dir == 0:
				$AnimatedSprite.play("idle")
			else:
				if is_sprinting:
					$AnimatedSprite.play("run_fast")
				else:
					$AnimatedSprite.play("run")
	else:
		if !is_attacking:
			if velocity.y < 0:
				if is_double_jumping:
					$AnimatedSprite.play("double_jump")
				else:
					$AnimatedSprite.play("jump")
			if velocity.y > 0:
				$AnimatedSprite.play("land")

func attack_input():
	if Input.is_action_pressed("ui_focus_next") && !is_attacking:
		is_attacking = true

		if attack_combo == 0:
			$AnimatedSprite.play("attack0")
			attack_combo = 1
		elif attack_combo == 1:
			$AnimatedSprite.play("attack1")
			attack_combo = 2
		elif attack_combo == 2:
			$AnimatedSprite.play("attack2")
			attack_combo = 0
			
func _on_AnimatedSprite_animation_finished():
	is_attacking = false

################# BETTER CAMERA
signal grounded_updated(is_grounded)
func better_camera():
	var was_grounded = is_grounded
	is_grounded = is_on_floor()
	
	if was_grounded == null || is_grounded != was_grounded:
		emit_signal("grounded_updated", is_grounded)
#################

################# DEBUGGING FOR THE MP/HP HUD
func test_HUD():
	if Input.is_action_just_pressed("ui_page_down"):
		get_node("Health").heal(3)
		get_node("Mana").gain_mana(3)
	if Input.is_action_just_pressed("ui_page_up"):
		get_node("Health").take_damage(3)
		get_node("Mana").use_mana(3)

func _on_Health_health_depleted():
	get_tree().change_scene("World.tscn")
#################
