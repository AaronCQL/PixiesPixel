extends Area2D

func _on_SwordHitBox_area_entered(area):
	if is_network_master():
		if area != get_node("./../../PlayerHitBox"):
			print(area.get_node("./../").get_name())
