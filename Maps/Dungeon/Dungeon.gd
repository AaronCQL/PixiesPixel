extends Node2D

func _ready():
	Network.connect("disconnected", self, "_on_disconnected")
	Network.connect("player_removed", self, "_on_player_removed")
	
func _on_player_removed(pinfo):
	despawn_player(pinfo)
	
func despawn_player(p_id):
	# Locate the player actor
	var player_node = get_node(str(p_id))
	# Mark the node for deletion
	player_node.queue_free()
	
func _on_disconnected():
	# Ideally pause the internal simulation and display a message box here.
	# From the answer in the message box change back into the main menu scene
	self.queue_free()
	get_tree().change_scene("res://MainMenu.tscn")
