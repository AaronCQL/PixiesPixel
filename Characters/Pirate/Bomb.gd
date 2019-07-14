extends Area2D

const SPEED = 100

var velocity = Vector2()
var direction = 1

func _ready():
	pass

func set_bomb_direction(dir):
	direction = dir
	if dir == -1:
		$Sprite.flip_h = true

func _physics_process(delta):
	velocity.x = SPEED * delta * direction
	translate(velocity)
	$Sprite/AnimationPlayer.current_animation = "activate"

func _on_VisibilityEnabler2D_screen_exited():
	queue_free()
