extends Node2D

func _ready():
	Network.connect("player_removed", self, "_on_player_removed")
	
func set_camera_limits(net_id):
	var player_node : String = "./" + net_id
	get_node(player_node).get_node("./Camera2D").limit_left = -16
	get_node(player_node).get_node("./Camera2D").limit_top = -16
	get_node(player_node).get_node("./Camera2D").limit_right = 688
	get_node(player_node).get_node("./Camera2D").limit_bottom = 576
	
func _on_player_removed(pinfo):
	despawn_player(pinfo)
	
func despawn_player(p_id):
	# Locate the player actor
	var player_node = get_node(str(p_id))
	# Mark the node for deletion
	player_node.queue_free()
	