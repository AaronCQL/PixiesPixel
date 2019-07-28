extends KinematicBody2D

const SPEED = 220
const MIN_DAMAGE = 3
const MAX_DAMAGE = 17
const FLOOR = Vector2(0, -1)

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var velocity : Vector2 = Vector2()

func _ready():
	rng.randomize()	

func _physics_process(delta):
	velocity = move_and_slide(velocity, FLOOR)
	$Sprite/AnimationPlayer.current_animation = "shoot"
	check_collision_with_wall()
		
func set_arrow_direction(dir):
	$Sprite.scale.x = dir
	velocity.x = SPEED * dir

func check_collision_with_wall():
	if is_on_wall():
		self.queue_free()

func _on_ArrowHitBox_area_entered(area):
	if is_network_master():
		if area.name == "PlayerHitBox":	
			if area.get_node("./..").name != str(get_tree().get_network_unique_id()): # Check if is not own hit box
				var actor = area.get_node("./../") # Get the player node that was hit
				var p_id_hit : String = str(actor.get_name()) # Get the id of the peer who was hit
				var p_id_sender : String = str(get_tree().get_network_unique_id()) # Get self id to let peer know who hit him
				var damage : int = rng.randi_range(MIN_DAMAGE, MAX_DAMAGE)
				actor.take_damage(p_id_hit, damage, p_id_sender)
				rpc("arrow_queue_free")

remotesync func arrow_queue_free():
	self.queue_free()