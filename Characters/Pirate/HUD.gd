extends CanvasLayer

func _ready():
	$AnimationPlayer.play("idle")

func _on_KinematicBody2D_ammo_updated(ammo):
	get_node("./Panel/BombCounter").text = str(ammo)
