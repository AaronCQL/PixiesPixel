extends CanvasLayer

var chosen_map : String = "res://Maps/Dungeon/Dungeon.tscn"

func setup_player_info():
	# allow player to choose which character and which map to play
	pass

func refresh_player_list():
	var PlayerList = get_node("./Panel/PlayerList")
	PlayerList.text = ""
	for id in Network.players:
		PlayerList.text += Network.players[id].name + " (" + str(Network.players[id].net_id) + ")" + "\n"

func _on_ready_to_play():
	get_tree().change_scene(chosen_map)

func _ready():
	refresh_player_list()
	Network.connect("player_list_changed", self, "refresh_player_list")
