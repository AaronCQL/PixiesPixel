extends KinematicBody2D

const SPEED = 200
const MIN_DAMAGE = 5
const MAX_DAMAGE = 22

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var velocity : Vector2 = Vector2()
var direction : int = 1

func _physics_process(delta):
	velocity.x = SPEED * direction
	move_and_slide(velocity)
	$Sprite/AnimationPlayer.current_animation = "shoot"
	if is_on_wall():
		queue_free()
		
func set_arrow_direction(dir):
	direction = dir
	if dir == -1:
		$Sprite.flip_h = true
