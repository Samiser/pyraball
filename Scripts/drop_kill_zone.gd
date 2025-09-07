extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		var player := body as Player
		if player.is_respawning:
			return
		player.respawn_player()
