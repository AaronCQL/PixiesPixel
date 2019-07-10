extends Node2D

func _ready():
	Network.connect("disconnected", self, "_on_disconnected")
	Network.connect("player_removed", self, "_on_player_removed")
	
	# Spawn the players
	if (get_tree().is_network_server()):
		spawn_players(Network.my_info, 1)
	else:
		rpc_id(1, "spawn_players", Network.my_info, -1)

# Spawns a new player actor, using the provided player_info structure and the given spawn index
remote func spawn_players(pinfo, spawn_index):
	# If the spawn_index is -1 then we define it based on the size of the player list
	if (spawn_index == -1):
		spawn_index = Network.players_info.size()
	
	if (get_tree().is_network_server() && pinfo.net_id != 1):
		# We are on the server and the requested spawn does not belong to the server
		# Iterate through the connected players
		var s_index = 1      # Will be used as spawn index
		for id in Network.players_info:
			# Spawn currently iterated player within the new player's scene, skipping the new player for now
			if (id != pinfo.net_id):
				rpc_id(pinfo.net_id, "spawn_players", Network.players_info[id], s_index)
			
			# Spawn the new player within the currently iterated player as long it's not the server
			# Because the server's list already contains the new player, that one will also get itself!
			if (id != 1):
				rpc_id(id, "spawn_players", pinfo, spawn_index)
			
			s_index += 1
	
	# Load the scene and create an instance
	var pclass = load(pinfo.actor_path)
	var nactor = pclass.instance()
	print(pinfo.name)
	# set actor position
	nactor.position = $SpawnPoints.get_node(str(spawn_index)).position
	# set actor infomation
	nactor.get_node("PlayerNameLabel").text = pinfo.name
	nactor.set_network_master(pinfo.net_id)
	nactor.set_name(str(pinfo.net_id))
	# Finally add the actor into the world
	add_child(nactor)
	
func _on_player_removed(pinfo):
	despawn_player(pinfo)
	
func despawn_player(pinfo):
	# Locate the player actor
	var player_node = get_node(str(pinfo.net_id))
	# Mark the node for deletion
	player_node.queue_free()
	
func _on_disconnected():
	# Ideally pause the internal simulation and display a message box here.
	# From the answer in the message box change back into the main menu scene
	get_tree().change_scene("res://MainMenu.tscn")
