extends KinematicBody2D

const SPEED = 200
const MIN_DAMAGE = 5
const MAX_DAMAGE = 22
const FLOOR = Vector2(0, -1)

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var velocity : Vector2 = Vector2()

func _physics_process(delta):
	move_and_slide(velocity)
	$Sprite/AnimationPlayer.current_animation = "shoot"
	check_collision()
		
func set_arrow_direction(dir):
	$Sprite.scale.x = dir
	velocity.x = SPEED * dir

func check_collision():
	if is_on_wall():
		queue_free()