extends Node

var server_info = {
	name = "Server",    # Holds the name of the server
	max_players = 0,    # Maximum allowed connections
	used_port = 0,      # Listening port
	ip_addr = '',		# IP address of the host
}

# Stores my player's info for the game
var my_info = {
	name = "Player",                   # How this player will be shown within the GUI
	net_id = 1,                        # By default everyone receives "server ID"
	actor_path = "res://Characters/Adventurer/Adventurer.tscn",  # The class used to represent the player in the game world
	actor_name = "Adventurer",
	spawnpoint = 0
}

var chosen_map : String = "Dungeon"

# Stores ALL players' info, including self. Looks like:
var players_info = {
#	1 = {
#		name = "Player",
#		net_id = 1,
#		actor_path = "res://Characters/Adventurer/Adventurer.tscn",
#		...
#	}
#   823475982372 = {
#		name = "Player",
#		net_id = 823475982372,
#		actor_path = "res://Characters/Adventurer/Adventurer.tscn",
#	 	...
#	}
}

signal server_created	  		# when server is successfully created
signal join_success	    		# When the peer successfully joins a server
signal join_fail   				# Failed to join a server
signal player_list_changed		# List of players has been changed
signal player_removed(id)		# A player has been removed from the list
signal disconnected				# To allow code outside to act when disconnected

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("server_disconnected", self, "on_disconnected_from_server")

func create_server():
	# Initialize the networking system
	var net = NetworkedMultiplayerENet.new()
	
	# Try to create the server
	if (net.create_server(server_info.used_port, server_info.max_players) == OK):
		# Assign it into the tree
		get_tree().set_network_peer(net)
		# Tell the server has been created successfully
		emit_signal("server_created")
		# Register the server's player in the local player list
		register_player(my_info)
		for address in IP.get_local_addresses():
			if "192.168" in address:
				server_info.ip_addr = address
				return
	else:
		print("Failed to create server")
		

func join_server(ip, port):
	var net = NetworkedMultiplayerENet.new()
	
	if (net.create_client(ip, port) == OK):
		get_tree().set_network_peer(net)
	else:
		print("Failed to create client")
		emit_signal("join_fail")

# When current machine successfully connects to server
func _on_connected_to_server():
	emit_signal("join_success")
	# Update the local player_info dictionary
	my_info.net_id = get_tree().get_network_unique_id()
	# Call all peers to register my player
	rpc("register_player", my_info)

remotesync func register_player(pinfo):
	if get_tree().is_network_server():
		# Distribute the player list information throughout the connected players
		for id in players_info:
			# Send currently iterated player info to the new player
			rpc_id(pinfo.net_id, "register_player", players_info[id])
			if id != 1:
				# Send new player info to currently iterated player
				rpc_id(id, "register_player", pinfo)
	
	players_info[pinfo.net_id] = pinfo	# Actually create the player entry in the dictionary
	emit_signal("player_list_changed") 	# Tell Lobby that player list is updated

# Everyone gets notified whenever a new client joins the server
func _on_player_connected(id):
	pass

# Peer trying to connect to server is notified on failure
func _on_connection_failed():
	emit_signal("join_fail")
	get_tree().set_network_peer(null)

# Executed on all the connected peers when another peer disconnects
func _on_player_disconnected(id):
	print("Player ", players_info[id].name, " disconnected from server")
	# Remove the player from the player list
	players_info.erase(id)
	# Tell Lobby to update the list
	emit_signal("player_list_changed")
	emit_signal("player_removed", id)

# Executed on the current machine when the current machine disconnects
func on_disconnected_from_server():
	print("Disconnected from server")
	# Stop processing any node in the world, so the client remains responsive
	get_tree().paused = true
	# Clear the network object
	get_tree().set_network_peer(null)
	# Allow outside code to know about the disconnection
	emit_signal("disconnected")
	# Clear the internal player list
	players_info.clear()
	# Reset the player info network ID
	my_info.net_id = 1
	my_info.spawnpoint = 0

func sync_spawnpoints():
	# Ask server to generate the spawnpoints
	if get_tree().is_network_server():
		var i = 1
		for id in players_info:
			# Ask server to sync all connected peers
			rpc("sync_client", id, i)
			i += 1

remotesync func sync_client(id, i):
	players_info[id].spawnpoint = i
	emit_signal("player_list_changed")