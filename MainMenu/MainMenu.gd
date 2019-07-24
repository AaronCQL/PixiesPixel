extends CanvasLayer

func _ready():
	Network.connect("server_created", self, "_on_connect_success")
	Network.connect("join_fail", self, "_on_join_fail")
	Network.connect("host_fail", self, "_on_host_fail")
	Network.connect("disconnected", self, "_on_disconnected")
	Network.connect("on_exit_button_pressed", self, "_show_main_menu")
	Network.connect("game_already_started", self, "_on_game_already_started")

func _on_HostButton_pressed():
	# Properly set the local player information
	set_player_info()
	
	# Gather values from the GUI and fill the network.server_info dictionary
	if (!$NetworkPanel/ServerIP.text.empty()):
		Network.server_info.name = $NetworkPanel/ServerIP.text
	Network.server_info.max_players = 6		
	
	# And create the server, using the function previously added into the code
	Network.create_server()

func _on_JoinButton_pressed():
	# Properly set the local player information
	set_player_info()
	
	var ip = $NetworkPanel/ServerIP.text
	Network.join_server(ip, 32788)
	
func set_player_info():
	if (!$NetworkPanel/PlayerName.text.empty()):
		Network.my_info.name = $NetworkPanel/PlayerName.text
		
func go_to_network_lobby():
	# Go to pre game lobby:
	var network_lobby = preload("res://Lobby/NetworkLobby/NetworkLobby.tscn").instance()
	get_node("/root").add_child(network_lobby)
	$NetworkPanel.hide()
	
func _on_connect_success():
	go_to_network_lobby()

func _on_join_fail():
	$NetworkPanel/JoinFailPopup.popup_centered()

func _on_host_fail():
	$NetworkPanel/HostFailPopup.popup_centered()

func _show_main_menu():
	$NetworkPanel.show()

func _on_disconnected():
	_show_main_menu()
	$NetworkPanel/DisconnectedPopup.popup_centered()

func _on_game_already_started():
	_show_main_menu()
	$NetworkPanel/GameAlreadyStartedPopup.popup_centered()

func _on_HelpButton_pressed():
	$NetworkPanel/HelpDialog.popup_centered()

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_SettingsButton_pressed():
	var settings_page = preload("res://Settings/Settings.tscn").instance()
	get_node("/root").add_child(settings_page)
	$NetworkPanel.hide()
