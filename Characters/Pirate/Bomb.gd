extends Area2D

const SPEED = 0

var velocity = Vector2()
var direction = 1
var is_exploding = false

onready var timer = get_node("Timer")

func _ready():
	timer.set_wait_time(2)
	timer.start(2)

func set_bomb_direction(dir):
	direction = dir
	if dir == -1:
		$Sprite.flip_h = true

func _physics_process(delta):
	if !is_exploding:
    	$Sprite/AnimationPlayer.current_animation = "activate"
	else:
    	$Sprite/AnimationPlayer.current_animation = "explode"
	

func _on_Timer_timeout():
	print("hulo")
	is_exploding = true

func _on_AnimationPlayer_animation_finished(explode):
	queue_free()
