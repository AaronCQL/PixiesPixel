extends Node2D

puppet var repl_health : int = 100

func _on_KinematicBody2D_health_updated(health):
	$TextureProgress.value = health
	rset("repl_health", health)
	
func _process(delta):
	if !is_network_master():
		$TextureProgress.value = repl_health