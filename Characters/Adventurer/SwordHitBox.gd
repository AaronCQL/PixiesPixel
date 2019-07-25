extends Area2D

const MIN_DAMAGE = 7
const MAX_DAMAGE = 15

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func _on_SwordHitBox_area_entered(area):
	if is_network_master():
		if area.name == "PlayerHitBox":	
			if area != get_node("./../../PlayerHitBox"): # Check if is not own hit box
				var actor = area.get_node("./../") # Get the Adventurer node that was hit
				var p_id_hit : String = str(actor.get_name()) # Get the id of the peer who was hit
				var p_id_sender : String = get_node('./../../').get_name() # Get self id to let peer know who hit him
				var damage : int = rng.randi_range(MIN_DAMAGE, MAX_DAMAGE)
				actor.take_damage(p_id_hit, damage, p_id_sender)