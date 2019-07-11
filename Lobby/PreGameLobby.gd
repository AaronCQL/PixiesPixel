extends CanvasLayer

func _ready():
	refresh_player_list()
	Network.connect("player_list_changed", self, "refresh_player_list")

func refresh_player_list():
	var PlayerList = get_node("./Panel/PlayerInfoPanel/PlayerList")
	PlayerList.text = ""
	for id in Network.players_info:
		PlayerList.text += Network.players_info[id].name + " (" + Network.players_info[id].actor_name + ") " + "s:" + str(Network.players_info[id].spawnpoint) + "\n"
	
func _on_Button2_pressed():
	if get_tree().is_network_server():
		sync_spawnpoints()
	else:
		rpc_id(1, "sync_spawnpoints")

remote func sync_spawnpoints():
	var i = 1
	for id in Network.players_info:
		rpc("sync_client", id, i)
		i += 1

remotesync func sync_client(id, i):
	Network.players_info[id].spawnpoint = i
	refresh_player_list()
	
		
remotesync func start_game():
	get_tree().change_scene("res://Maps/Dungeon/Dungeon.tscn")

remotesync func update_player_list(net_id_to_change, new_player_info):
	Network.players_info[net_id_to_change] = new_player_info
	refresh_player_list()

func _on_PirateButton_pressed():
	# get network id of the person who pressed
	var net_id_to_change : int = Network.my_info.net_id
	# change local state
	Network.my_info.actor_name = "Pirate"
	Network.my_info.actor_path = "res://Characters/Pirate/Pirate.tscn"
	# ask everybody else to change their player list
	rpc("update_player_list", net_id_to_change, Network.my_info)

func _on_AdventurerButton_pressed():
	# get network id of the person who pressed
	var net_id_to_change : int = Network.my_info.net_id
	# change local state
	Network.my_info.actor_name = "Adventurer"
	Network.my_info.actor_path = "res://Characters/Adventurer/Adventurer.tscn"
	# ask everybody else to change their player list
	rpc("update_player_list", net_id_to_change, Network.my_info)

func _on_ExitButton_pressed():
	Network.on_disconnected_from_server()
	get_tree().change_scene("res://MainMenu.tscn")

func _on_MapButton_pressed():
	rpc("go_to_map")

remotesync func go_to_map():
	var world = load("res://Maps/Dungeon/Dungeon.tscn").instance()
	get_node("/root").add_child(world)
	for p in Network.players_info:
		var actor_path : String = Network.players_info[p].actor_path
		var spawnpoint : String = str(Network.players_info[p].spawnpoint)
		var player = load(actor_path).instance()
		player.position = get_node("/root/Map2/SpawnPoints").get_node(spawnpoint).position
		player.set_name(str(p))
		player.set_network_master(p) # Will be explained later
		world.add_child(player)
	self.queue_free()