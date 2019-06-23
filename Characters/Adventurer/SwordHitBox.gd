extends Area2D

var rng = RandomNumberGenerator.new()

func _on_SwordHitBox_area_entered(area):
	if area != get_node("../../PlayerHitBox"):
		var amount : int = rng.randi_range(12, 18)
		area.take_damage(amount)

func _ready():
	rng.randomize()