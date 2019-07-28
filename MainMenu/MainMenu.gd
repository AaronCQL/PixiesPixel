extends CanvasLayer

var config : ConfigFile

var display_name : String
var ip_addr : String

func _ready():
	Network.connect("server_created", self, "_on_connect_success")
	Network.connect("join_fail", self, "_on_join_fail")
	Network.connect("host_fail", self, "_on_host_fail")
	Network.connect("disconnected", self, "_on_disconnected")
	Network.connect("on_exit_button_pressed", self, "_show_main_menu")
	Network.connect("game_already_started", self, "_on_game_already_started")
	init_config()
	
func init_config():
	config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK: # if not, something went wrong with the file loading
		display_name = config.get_value("main_menu", "display_name", "")
		$NetworkPanel/PlayerName.text = display_name
		
		ip_addr = config.get_value("main_menu", "ip_addr", "127.0.0.1")
		$NetworkPanel/ServerIP.text = ip_addr
	
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
		display_name = $NetworkPanel/PlayerName.text
		Network.my_info.name = display_name
	ip_addr = $NetworkPanel/ServerIP.text
	config.set_value("main_menu", "display_name", display_name)
	config.set_value("main_menu", "ip_addr", ip_addr)
	config.save("user://settings.cfg")
		
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
	$NetworkPanel.hide()
	get_node("/root/Settings/Panel").show()

func _on_ControlsButton_pressed():
	$Controls/Panel.show()
