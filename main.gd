extends Node3D

@onready var player: Player = $Player

enum Level {BACK, PRESENT, FORWARD}
var current_level: Level = Level.PRESENT

func get_level_rotation(level: Level) -> Vector3:
	match level:
		Level.BACK:
			return Vector3(deg_to_rad(65), 0, 0)
		Level.PRESENT:
			return Vector3(0, deg_to_rad(90), deg_to_rad(65))
		Level.FORWARD:
			return Vector3(-deg_to_rad(65), deg_to_rad(180), 0)
		#Level.VOID:
			#return Vector3(0, deg_to_rad(270), -deg_to_rad(65))
	
	return Vector3.ZERO

func _on_rotation(direction: String, player_position: Vector3) -> void:
	if direction == "left":
		current_level = posmod(current_level - 1, 3)
	elif direction == "right":
		current_level = posmod(current_level + 1, 3)

	match current_level:
		Level.BACK:
			player.set_new_scale(0.2)
		Level.PRESENT:
			player.set_new_scale(0.5)
		Level.FORWARD:
			player.set_new_scale(3)

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property($PyraWorld, "rotation", get_level_rotation(current_level), 0.3)
	await tween.finished
	player.rotation_completed(player_position)

func _ready() -> void:
	$Player.rotate.connect(_on_rotation)
