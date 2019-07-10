extends CanvasLayer

func _on_HostButton_pressed():
	# Properly set the local player information
	set_player_info()
	
	# Gather values from the GUI and fill the network.server_info dictionary
	if (!$NetworkPanel/ServerIP.text.empty()):
		Network.server_info.name = $NetworkPanel/ServerIP.text
	Network.server_info.used_port = int($NetworkPanel/ServerPort.text)
	Network.server_info.max_players = 6		
	
	# And create the server, using the function previously added into the code
	Network.create_server()

func _on_JoinButton_pressed():
	# Properly set the local player information
	set_player_info()
	
	var port = int($NetworkPanel/ServerPort.text)
	var ip = $NetworkPanel/ServerIP.text
	Network.join_server(ip, port)
	
func set_player_info():
	if (!$NetworkPanel/PlayerName.text.empty()):
		GameState.player_info.name = $NetworkPanel/PlayerName.text

func _on_connect_success():
	# FOR INSTANT CHANGE SCENE:
	# get_tree().change_scene("res://Maps/Dungeon/Dungeon.tscn")
	
	# FOR GOING TO LOBBY:
	get_tree().change_scene("res://Lobby/PreGameLobby.tscn")

func _on_join_fail():
	# Change to displaying error message when finalising
	print("Failed to join server")
	
func _ready():
	Network.connect("server_created", self, "_on_connect_success")
	Network.connect("join_success", self, "_on_connect_success")
	Network.connect("join_fail", self, "_on_join_fail")
	get_tree().paused = false

