extends Area2D

var rng = RandomNumberGenerator.new()

func _on_SwordHitBox_area_entered(area):
	if is_network_master():
		if area.name == "PlayerHitBox":	
			if area != get_node("./../../PlayerHitBox"): # Check if is not own hit box
				var actor = area.get_node("./../")
				var p_id_hit = actor.get_name()
				rpc_id(p_id_hit, actor.take_damage, 10)
				print(p_id_hit)

func _ready():
	rng.randomize()