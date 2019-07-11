extends CanvasLayer

func _ready():
	refresh_player_list()
	Network.connect("player_list_changed", self, "refresh_player_list")

func refresh_player_list():
	var PlayerList = get_node("./Panel/PlayerInfoPanel/PlayerList")
	PlayerList.text = ""
	for id in Network.players_info:
		if id == 1:
			PlayerList.text += Network.players_info[id].name + " S:" + str(Network.players_info[id].spawnpoint) + " (Host)" + "\n"
		else:
			PlayerList.text += Network.players_info[id].name  + " S:" + str(Network.players_info[id].spawnpoint) + "\n"
	
func _on_StartButton_pressed():
	rpc("go_to_pre_game_lobby")

remotesync func go_to_pre_game_lobby():
	Network.sync_spawnpoints()
	get_tree().change_scene("res://Lobby/PreGameLobby/PreGameLobby.tscn")

func _on_ExitButton_pressed():
	Network.on_disconnected_from_server()
	get_tree().change_scene("res://MainMenu.tscn")




