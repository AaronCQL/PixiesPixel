extends Area2D

const THROW_VELOCITY = Vector2(800, -400)
const GRAVITY = 10

var velocity = Vector2.ZERO

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	#var collision = move_and_collide(velocity * delta)
	