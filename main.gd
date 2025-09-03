extends Node3D

@onready var player: Player = $Player

func _on_rotation(direction: String, player_position: Vector3) -> void:
	var tween := create_tween()
	tween.tween_property(player, "global_position:y", 30, 2)
	tween.tween_property($PyraWorld, "rotation", Vector3(0, 0, deg_to_rad(115)), 3)
	tween.tween_property($PyraWorld, "rotation", Vector3(0, deg_to_rad(90), 0), 3)
	tween.tween_property($PyraWorld, "rotation", Vector3(deg_to_rad(115), 0, 0), 3)
	await tween.finished
	player.on_rotation_completed(player_position)

func _ready() -> void:
	$Player.rotate.connect(_on_rotation)
