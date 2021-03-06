extends KinematicBody2D

signal health_updated(health)

const MAX_HEALTH = 100
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

var is_sprinting : bool = false
var can_double_jump : bool = true
var is_double_jumping : bool = false
var is_attacking : bool = false
var attack_combo : int = 0
var health : int = MAX_HEALTH
var is_dead : bool = false
var show_menu : bool = false
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var velocity : Vector2 = Vector2(0, 0)

puppet var repl_position : Vector2 = Vector2()
puppet var repl_animation : String = "idle"
puppet var repl_scale_x : int = 1
puppet var repl_is_dead : bool = false

var p_id_last_hit : String 		# Last player to hit this guy, for KDR

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	gravity = MAX_JUMP_HEIGHT / pow(TIME_TO_JUMP_APEX, 2)
	max_jump_velocity = -sqrt(2 * gravity * MAX_JUMP_HEIGHT)
	min_jump_velocity = -sqrt(2 * gravity * MIN_JUMP_HEIGHT)
	$Sprite.get_node("./SwordHitBox/CollisionShape2D").disabled = true # Disables sword hit box on start
	if is_network_master():
		self.z_index = 10 # Make character you control display in front of peers
	
func _physics_process(delta):
	if is_network_master():
		direction_input()				# horizontal mvmt
		sprint_input()
		jump_input()					# jump
		attack_input()
		acceleration_curve()			# simluate acceleration when moving
		flip_sprite(x_dir)				# flips sprite when turning direction
		play_animation(x_dir)
		check_death()
		toggle_menu()
		velocity.y += gravity * delta 	# gravity
		velocity = move_and_slide(velocity, FLOOR)	# godot's physics
		rset_unreliable("repl_position", position)
		rset("repl_animation", $AnimationPlayer.current_animation)
	else:
		position = lerp(position, repl_position, 0.5)		# to replitcate current position
		$AnimationPlayer.current_animation = repl_animation # to replicate current animation
		$Sprite.scale.x = repl_scale_x 						# to replicate change in x direction
		if repl_is_dead:
			$PlayerHitBox/CollisionShape2D.disabled = true		
	
func direction_input():
	x_dir = 0
	if !is_dead:
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
	if Input.is_action_pressed("ui_focus_next") && !is_attacking && !is_dead:
		is_attacking = true
		$AudioStreamPlayer2D.pitch_scale = rng.randf_range(1.0, 1.4)	
		
		if attack_combo == 0:
			$AnimationPlayer.current_animation = "attack1"
			attack_combo = 1
		elif attack_combo == 1:
			$AnimationPlayer.current_animation = "attack2"
			attack_combo = 2
		elif attack_combo == 2:
			$AnimationPlayer.current_animation = "attack3"
			attack_combo = 0
	
func jump_input():
	if !is_dead:
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
	if !is_dead:
		if is_on_floor():
			if !is_attacking:
				if x_dir == 0:
					$AnimationPlayer.current_animation = "idle"
				else:
					if is_sprinting:
						$AnimationPlayer.current_animation = "sprint"
					else:
						$AnimationPlayer.current_animation = "run"
		else:
			if !is_attacking:
				if velocity.y < 0:
					if is_double_jumping:
						$AnimationPlayer.current_animation = "double_jump"
					else:
						$AnimationPlayer.current_animation = "jump"
				if velocity.y > 0:
					$AnimationPlayer.current_animation = "fall"

# warning-ignore:unused_argument
func _on_AnimationPlayer_animation_finished(attack1):
	is_attacking = false
	
func toggle_menu():
	if Input.is_action_just_pressed("ui_cancel"):
		show_menu = !show_menu
	if show_menu:
		get_node('./InGameMenu/Panel').show()
	else:
		get_node('./InGameMenu/Panel').hide()
		
func _on_InGameMenu_on_resume_button_pressed():
	show_menu = false

func check_death():
	if !is_dead:
		$Camera2D.make_current()
		if health <= 0:
			is_dead = true
			rset("repl_is_dead", true)
			$AnimationPlayer.current_animation = "die"
			$DeathTimer.start(2)
			Network.on_player_death(get_tree().get_network_unique_id())
			rpc("update_score_board", p_id_last_hit, get_tree().get_network_unique_id())
			$PlayerHitBox/CollisionShape2D.disabled = true	
			print("Slain by " + p_id_last_hit)
	if is_dead:
		change_camera()
		
remotesync func update_score_board(p_id_killer, p_id_dead):
	$ScoreBoard.update_score_board(p_id_killer, p_id_dead)

func _on_DeathTimer_timeout():
	$Camera2D.current = false
	get_node("./../" + str(Network.remaining_players[0]) + "/Camera2D").make_current()
	if Network.remaining_players.size() == 1:
		rpc("show_score_board")

remotesync func show_score_board():
	$ScoreBoard.show_score_board()	

var cam_index : int = 0
func change_camera():
	if Input.is_action_just_pressed("ui_focus_next"):
		if (cam_index >= Network.remaining_players.size() - 1):
			cam_index = 0
		else:
			cam_index += 1	
		get_node("./../" + str(Network.remaining_players[cam_index]) + "/Camera2D").make_current()
		
func take_damage(p_id_hit, amount, p_id_sender):
	rpc("send_damage_info", p_id_hit, amount, p_id_sender)

remotesync func send_damage_info(p_id_hit, amount, p_id_sender):
	# Get the actual player node that was hit using the network_id
	var player_hit = get_node("./../" + p_id_hit)
	player_hit.get_node("./DamageAnimation").current_animation = "damage"
	player_hit.set_health(player_hit.health - amount)
	player_hit.p_id_last_hit = p_id_sender
		
func set_health(value):
# warning-ignore:narrowing_conversion
	health = clamp(value, 0, MAX_HEALTH)
	emit_signal("health_updated", health) # For health bar

