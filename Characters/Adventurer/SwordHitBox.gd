extends Area2D

onready var own_net_id = get_tree().get_network_unique_id()

func _on_SwordHitBox_body_entered(body):
	print(get_node("../../").get_children())
	#if (body.net_id != own_net_id):
	#	rpc_id(body.net_id, "take_damage", 5)
		
remote func take_damage(value):
	print("work")