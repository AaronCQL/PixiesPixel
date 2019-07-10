extends CanvasLayer

var chosen_map : String = "res://Maps/Dungeon/Dungeon.tscn"

func setup_player_info():
	# allow player to choose which character and which map to play
	pass

func refresh_player_list():
	var PlayerList = get_node("./Panel/PlayerInfoPanel/PlayerList")
	PlayerList.text = ""
	for id in Network.players_info:
		PlayerList.text += Network.players_info[id].name + " (" + Network.players_info[id].actor_name + ") " + "\n"

func _on_ready_to_play():
	get_tree().change_scene(chosen_map)

func _ready():
	refresh_player_list()
	Network.connect("player_list_changed", self, "refresh_player_list")
	
func _on_Button2_pressed():
	rpc("start_game")
	
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
