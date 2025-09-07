extends Node3D

var has_player_entered := false

# removed old functionality - might not need this script anymore

func _on_area_3d_body_entered(body: Node3D) -> void:
	if !body is Player:
		return
		
	has_player_entered = true
