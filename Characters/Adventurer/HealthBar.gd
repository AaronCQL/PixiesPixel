extends Node2D

func _on_KinematicBody2D_health_updated(health):
	$TextureProgress.value = health