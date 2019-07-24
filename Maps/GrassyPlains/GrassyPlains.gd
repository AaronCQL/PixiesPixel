extends Node2D

func _ready():
	Network.connect("player_removed", self, "_on_player_removed")
	var audio_player = get_node("/root/Settings/AudioStreamPlayer")
	audio_player.stream = load("res://Assets/Music/8-Bit-Techno.ogg")
	audio_player.play()
	
func set_camera_limits(net_id):
	var player_node : String = "./" + net_id
	get_node(player_node).get_node("./Camera2D").limit_left = 0
	get_node(player_node).get_node("./Camera2D").limit_top = -208
	get_node(player_node).get_node("./Camera2D").limit_right = 1520
	get_node(player_node).get_node("./Camera2D").limit_bottom = 416
	
func _on_player_removed(pinfo):
	despawn_player(pinfo)
	
func despawn_player(p_id):
	# Locate the player actor
	var player_node = get_node(str(p_id))
	# Mark the node for deletion
	player_node.queue_free()
	