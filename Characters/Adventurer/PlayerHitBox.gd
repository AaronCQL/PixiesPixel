extends Area2D

func take_damage(amount):
	var root_node = get_node("../")
	print("took " + str(amount) + " of damage")
	root_node.take_damage(amount)