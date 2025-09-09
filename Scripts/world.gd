extends Node3D

@onready var environment: Environment = $WorldEnvironment.environment
@export var player: Player
@export var ui: UI

enum LevelEnum {BACK, PRESENT, FORWARD, VOID}
var current_level: LevelEnum = LevelEnum.PRESENT
var last_level := 0

signal puzzle_completed(name: String)
signal portalled

func get_level_rotation(level: LevelEnum) -> Vector3:
	match level:
		LevelEnum.BACK:
			return Vector3(deg_to_rad(63.5), 0, 0)
		LevelEnum.PRESENT:
			return Vector3(0, deg_to_rad(90), deg_to_rad(63.5))
		LevelEnum.FORWARD:
			return Vector3(-deg_to_rad(63.5), deg_to_rad(180), 0)
		LevelEnum.VOID:
			return Vector3(0, deg_to_rad(270), -deg_to_rad(63.5))
	
	return Vector3.ZERO

func _tween_fog_color(new_color: Color, fog_far_dist: float) -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(environment, "fog_light_color", new_color, 1)
	tween.parallel().tween_property(environment, "fog_depth_end", fog_far_dist, 1)
	tween.parallel().tween_property(player.camera, "far", fog_far_dist, 1)

func _tween_daylight(new_rot: Vector3, new_colour: Color) -> void:
	var tween := create_tween()
	tween.tween_property($DirectionalLight3D as Node3D, "rotation_degrees", new_rot, 1.0)
	tween.parallel().tween_property($DirectionalLight3D as DirectionalLight3D, "light_color", new_colour, 1.0)

func _tween_rotation(new_rotation: Vector3) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property($PyraWorld, "rotation", get_level_rotation(current_level), 2)
	await tween.finished
	return

func _apply_world_changes() -> void:
	var audio_stream :AudioStreamPlayer= $AudioStreamPlayer
	if last_level < current_level:
		audio_stream.stream = load("res://Audio/SoundFX/time_forward.mp3")
	else:
		audio_stream.stream = load("res://Audio/SoundFX/time_back.mp3")
	audio_stream.play()
	
	last_level = current_level
	match current_level:
		LevelEnum.BACK:
			player.set_new_scale(0.2, current_level)
			_tween_fog_color(Color.from_hsv(0.6, 0.6, 1.0), 32.0)
			_tween_daylight(Vector3(-90.0, 0.0, 0.0), Color.WHITE)
		LevelEnum.PRESENT:
			player.set_new_scale(0.5, current_level)
			_tween_fog_color(Color.from_hsv(0.7, 0.6, 0.6), 99.0)
			_tween_daylight(Vector3(-172.0, 0.0, 0.0), Color.BLUE_VIOLET)
		LevelEnum.FORWARD:
			player.set_new_scale(3, current_level)
			_tween_fog_color(Color.from_hsv(0.95, 0.6, 1.0), 99.0)
			_tween_daylight(Vector3(-40.0, 0.0, 0.0), Color.FLORAL_WHITE)
		LevelEnum.VOID:
			player.set_new_scale(10, current_level)
			_tween_fog_color(Color.from_hsv(0.5, 0.4, 1.0), 94.0)
			_tween_daylight(Vector3(0.0, 0.0, 0.0), Color.BLUE_VIOLET)
	
	ui._on_time_change(current_level)

func _change_current_level(direction: String, levels_unlocked: int) -> void:
	if direction == "left":
		current_level = posmod(current_level - 1, levels_unlocked)
	elif direction == "right":
		current_level = posmod(current_level + 1, levels_unlocked)

func _on_rotation(direction: String, player_position: Vector3, levels_unlocked: int) -> void:
	_change_current_level(direction, levels_unlocked)
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
	for world: Level in [$PyraWorld/Past, $PyraWorld/Present, $PyraWorld/Future]:
		world.puzzle_completed.connect(func(name: String) -> void: puzzle_completed.emit(name))
		world.portalled.connect(func() -> void: portalled.emit())
