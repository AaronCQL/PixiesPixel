extends CanvasLayer

var chosen_map : String = "res://Maps/Dungeon/Dungeon.tscn"

func setup_player_info():
	# allow player to choose which character and which map to play
	pass

func refresh_player_list():
	# refreshes the player list info whenever another client changes his character
	# use Kehom's on_player_list_changed
	pass

func _on_ready_to_play():
	get_tree().change_scene(chosen_map)
