extends KinematicBody2D

const GRAVITY = 1
const FLOOR = Vector2(0, -1)

var velocity = Vector2()
var is_exploding = false

onready var timer = get_node("Timer")

func _ready():
	timer.set_wait_time(2)
	timer.start(2)

func _physics_process(delta):
	if !is_exploding:
    	$Sprite/AnimationPlayer.current_animation = "activate"
	else:
    	$Sprite/AnimationPlayer.current_animation = "explode"
		
	velocity.y += GRAVITY
	move_and_slide(velocity, FLOOR)
	

func _on_Timer_timeout():
	is_exploding = true

func _on_AnimationPlayer_animation_finished(explode):
	queue_free()
