extends Area2D

var rng = RandomNumberGenerator.new()

func _on_SwordHitBox_area_entered(area):
	if area != get_node("../../PlayerHitBox"):
		if area.name == "PlayerHitBox":
			var amount : int = rng.randi_range(1, 20)
			area.take_damage(amount)

func _ready():
	rng.randomize()