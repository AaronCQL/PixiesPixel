extends KinematicBody2D

const SPEED = 180
const MIN_DAMAGE = 5
const MAX_DAMAGE = 22

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var velocity : Vector2 = Vector2()

func _ready():
	pass

func _physics_process(delta):
	velocity.x = SPEED
	move_and_slide(velocity)
	$Sprite/AnimationPlayer.current_animation = "shoot"
