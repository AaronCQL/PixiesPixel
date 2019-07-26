extends CanvasLayer

var score_board = {
#	1 = {
#		name = "some player",
#		kills = 2,
#		killed_by = "another player"
#	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel.hide()
	init_score_board()
	
func init_score_board():
	for p_id in Network.players_info:
		score_board[p_id] = {
			name = Network.players_info[p_id].name,
			kills = 0,
			killed_by = ""
		}
	print(score_board)
		
func update_score_board(p_id_killer, p_id_dead):
	score_board[int(p_id_killer)].kills += 1
	score_board[int(p_id_dead)].killed_by = score_board[int(p_id_killer)].name
	
func show_score_board():
	for p_id in score_board:
		var table_row = load("res://Characters/ScoreBoard/TableRowPlayerData.tscn").instance()
		table_row.get_node("NameLabel").text = score_board[p_id].name
		table_row.get_node("KillsLabel").text = str(score_board[p_id].kills)
		table_row.get_node("KilledByLabel").text = score_board[p_id].killed_by
		get_node("./Panel/TablePanel/TableRows").add_child(table_row)
	$Panel.show()
	
func _on_ExitButton_pressed():
	Network.exit_to_main_menu()

func _on_RematchButton_pressed():
	rpc("go_to_network_lobby")

remotesync func go_to_network_lobby():
	Network.chosen_map = "Dungeon"
	var network_lobby = preload("res://Lobby/NetworkLobby/NetworkLobby.tscn").instance()
	get_node("/root").add_child(network_lobby)
	Network.change_bg_music()
	get_node("/root/Map").queue_free()
