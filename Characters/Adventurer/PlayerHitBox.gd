extends Area2D

var rng = RandomNumberGenerator.new()

func take_damage(amount):
	var root_node = get_node("../")
	root_node.take_damage(amount)

func _on_PlayerHitBox_area_entered(area):
	if area.name != "PlayerHitBox": 				 	# check is not other player bodies
		if area != get_node("../Sprite/SwordHitBox"): 	# check is not own sword
			if area.name == "SwordHitBox":
				var amount : int = rng.randi_range(1, 20)
				take_damage(0)

func _ready():
	rng.randomize()