extends Node3D

@onready var player: Player = $Player

enum Level {BACK, PRESENT, FORWARD, VOID}
var current_level: Level = Level.BACK

func get_level_rotation(level: Level) -> Vector3:
	match level:
		Level.BACK:
			return Vector3(deg_to_rad(65), 0, 0)
		Level.PRESENT:
			return Vector3(0, deg_to_rad(90), deg_to_rad(65))
		Level.FORWARD:
			return Vector3(-deg_to_rad(65), deg_to_rad(180), 0)
		Level.VOID:
			return Vector3(0, deg_to_rad(270), -deg_to_rad(65))
	
	return Vector3.ZERO

func _on_rotation(direction: String, player_position: Vector3) -> void:
	current_level = (current_level + 1) % 4
	print(current_level)
	var tween := create_tween()
	tween.tween_property(player, "global_position:y", 150, 2)
	tween.tween_property($PyraWorld, "rotation", get_level_rotation(current_level), 3)
	await tween.finished
	player.on_rotation_completed(player_position)

func _ready() -> void:
	$Player.rotate.connect(_on_rotation)
