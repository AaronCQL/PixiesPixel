extends CanvasLayer

func _ready():
	refresh_player_list()
	Network.connect("player_list_changed", self, "refresh_player_list")

func refresh_player_list():
	var player_list = get_node("./Panel/PlayerInfoPanel/PlayerList")
	var text_to_display : String
	for id in Network.players_info:
		if id == 1:
			text_to_display += Network.players_info[id].name + " (Host)" + "\n"
		else:
			text_to_display += Network.players_info[id].name + "\n"
	player_list.text = text_to_display
	
func _on_StartButton_pressed():
	rpc("go_to_pre_game_lobby")

remotesync func go_to_pre_game_lobby():
	Network.sync_spawnpoints()
	get_tree().change_scene("res://Lobby/PreGameLobby/PreGameLobby.tscn")

func _on_ExitButton_pressed():
	Network.on_disconnected_from_server()
	get_tree().change_scene("res://MainMenu.tscn")




