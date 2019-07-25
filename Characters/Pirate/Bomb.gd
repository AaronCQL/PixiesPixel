extends KinematicBody2D

const GRAVITY : int = 125
const FLOOR : Vector2 = Vector2(0, -1)
const MIN_DAMAGE = 5
const MAX_DAMAGE = 22

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var velocity : Vector2 = Vector2()
var is_exploding : bool

onready var timer = get_node("Timer")

func _ready():
	rng.randomize()
	is_exploding = false
	timer.start(2)

func _physics_process(delta):
	if !is_exploding:
		$Sprite/AnimationPlayer.current_animation = "activate"
		velocity.y += GRAVITY * delta
		move_and_slide(velocity, FLOOR)
	else:
		$Sprite/AnimationPlayer.current_animation = "explode"

func _on_Timer_timeout():
	is_exploding = true

func _on_AnimationPlayer_animation_finished(explode):
	queue_free()

func _on_BombHitBox_area_entered(area):
	if is_network_master():
		if area.name == "PlayerHitBox":	
			if area.get_node("./..").name != str(get_tree().get_network_unique_id()): # Check if is not own hit box
				if is_exploding:
					var actor = area.get_node("./../") # Get the Adventurer node that was hit
					var p_id_hit : String = str(actor.get_name()) # Get the id of the peer who was hit
					var p_id_sender : String = str(get_tree().get_network_unique_id()) # Get self id to let peer know who hit him
					var damage : int = rng.randi_range(MIN_DAMAGE, MAX_DAMAGE)
					actor.take_damage(p_id_hit, damage, p_id_sender)
				else:
					rpc("explode_bomb")
					
remotesync func explode_bomb():
	is_exploding = true
	