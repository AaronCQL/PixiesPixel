extends KinematicBody2D

const THROW_VELOCITY = Vector2(800, -400)
const GRAVITY = 10

var velocity = Vector2(0, 0)

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	var collision = move_and_collide(velocity * delta) 		#collision data to know whether you hit sth
	if collision != null:
		_on_impact(collision.normal)
		
func launch(direction):
	#reparent so that it's position is no longer relative to the character's hand
	#bomb is indep of character's arm
	var temp = global_transform
	var scene = get_tree().current_scene
	get_parent().remove_child(self)
	scene.add_child(self)
	global_transform = temp
	velocity = THROW_VELOCITY * Vector2(direction, 1)
	set_physics_process(true)

func _on_impact(normal : Vector2):		
	$Sprite/AnimationPlayer.current_animation = "explode" 