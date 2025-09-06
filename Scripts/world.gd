extends Node3D

@onready var environment: Environment = $WorldEnvironment.environment
@export var player: Player
@export var minimap_camera: Camera3D

enum Level {BACK, PRESENT, FORWARD, VOID}
var current_level: Level = Level.PRESENT

func get_level_rotation(level: Level) -> Vector3:
	match level:
		Level.BACK:
			return Vector3(deg_to_rad(65), 0, 0)
		Level.PRESENT:
			return Vector3(0, deg_to_rad(90), deg_to_rad(63.5))
		Level.FORWARD:
			return Vector3(-deg_to_rad(63.5), deg_to_rad(180), 0)
		Level.VOID:
			return Vector3(0, deg_to_rad(270), -deg_to_rad(63.5))
	
	return Vector3.ZERO

func _tween_fog_color(new_color: Color, new_density: float) -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(environment, "fog_light_color", new_color, 1)
	tween.parallel().tween_property(environment, "fog_density", new_density, 1)
	tween.parallel().tween_property(minimap_camera, "environment:fog_light_color", new_color, 1)

func _tween_rotation(new_rotation: Vector3) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property($PyraWorld, "rotation", get_level_rotation(current_level), 0.3)
	await tween.finished
	return

func _apply_world_changes() -> void:
	match current_level:
		Level.BACK:
			player.set_new_scale(0.2)
			_tween_fog_color(Color.from_hsv(0.6, 0.6, 1.0), 0.015)
		Level.PRESENT:
			player.set_new_scale(0.5)
			_tween_fog_color(Color.from_hsv(0.7, 0.6, 1.0), 0.005)
		Level.FORWARD:
			player.set_new_scale(3)
			_tween_fog_color(Color.from_hsv(0.95, 0.6, 1.0), 0.001)
		Level.VOID:
			player.set_new_scale(10)
			_tween_fog_color(Color.from_hsv(0.5, 0.4, 1.0), 0.001)

func _change_current_level(direction: String) -> void:
	if direction == "left":
		current_level = posmod(current_level - 1, 3)
	elif direction == "right":
		current_level = posmod(current_level + 1, 3)

func _on_rotation(direction: String, player_position: Vector3) -> void:
	_change_current_level(direction)
	_apply_world_changes()
	await _tween_rotation(get_level_rotation(current_level))
	player.rotation_completed(player_position)

func _on_all_crystals_collected(player_position: Vector3) -> void:
	current_level = 3
	_apply_world_changes()
	await _tween_rotation(get_level_rotation(current_level))
	player_position = Vector3(0, 0, 0)
	player.rotation_completed(player_position)

func _ready() -> void:
	_apply_world_changes()
