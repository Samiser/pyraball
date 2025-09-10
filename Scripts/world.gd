extends Node3D

@onready var environment: Environment = $WorldEnvironment.environment
@export var player: Player
@export var ui: UI

enum LevelEnum {BACK, PRESENT, FORWARD, VOID}
var current_level: LevelEnum = LevelEnum.PRESENT
var last_level := 0

signal puzzle_completed(name: String)
signal portalled
signal outside(value: bool)

signal game_finished

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

func _tween_fog_color(new_color: Color, new_density: float) -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(environment, "fog_light_color", new_color, 1)
	#tween.parallel().tween_property(environment, "fog_density", new_density, 1)

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

func _apply_world_changes(play_sound: bool = true) -> void:
	if play_sound:
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
			_tween_fog_color(Color.from_hsv(0.6, 0.6, 1.0), 0.015)
			_tween_daylight(Vector3(-90.0, 0.0, 0.0), Color.WHITE)
		LevelEnum.PRESENT:
			player.set_new_scale(0.5, current_level)
			_tween_fog_color(Color.from_hsv(0.7, 0.6, 0.6), 0.005)
			_tween_daylight(Vector3(-172.0, 0.0, 0.0), Color.BLUE_VIOLET)
		LevelEnum.FORWARD:
			player.set_new_scale(3, current_level)
			_tween_fog_color(Color.from_hsv(0.95, 0.6, 1.0), 0.001)
			_tween_daylight(Vector3(-40.0, 0.0, 0.0), Color.FLORAL_WHITE)
		LevelEnum.VOID:
			player.set_new_scale(10, current_level)
			_tween_fog_color(Color.from_hsv(0.5, 0.4, 1.0), 0.001)
			_tween_daylight(Vector3(0.0, 0.0, 0.0), Color.BLUE_VIOLET)
	
	ui._on_time_change(current_level)

func _change_current_level(direction: String, levels_unlocked: int) -> void:
	if direction == "left":
		current_level = posmod(current_level - 1, levels_unlocked)
	elif direction == "right":
		current_level = posmod(current_level + 1, levels_unlocked)

func _freeze_buttons(value: bool) -> void:
	for button: Node3D in get_tree().get_nodes_in_group("button"):
		if button.has_method("set_freeze"):
			button.set_freeze(value)

func _on_rotation(direction: String, player_position: Vector3, levels_unlocked: int) -> void:
	_freeze_buttons(true)
	_change_current_level(direction, levels_unlocked)
	_apply_world_changes()
	await _tween_rotation(get_level_rotation(current_level))
	player.rotation_completed(player_position)
	_freeze_buttons(false)

func _on_all_crystals_collected(player_position: Vector3) -> void:
	game_finished.emit()
	current_level = 3
	_apply_world_changes(false)
	await get_tree().create_timer(3.0).timeout
	await _tween_rotation(get_level_rotation(current_level))
	player_position = Vector3.ZERO
	player.rotation_completed(player_position)
	await get_tree().create_timer(8.0).timeout
	ui.fade_out()

func _ready() -> void:
	_apply_world_changes(false)
	for portal: Node3D in get_tree().get_nodes_in_group("portal"):
		if portal.has_signal("outside"):
			portal.outside.connect(func(value: bool) -> void: outside.emit(value))
	for world: Level in [$PyraWorld/Past, $PyraWorld/Present, $PyraWorld/Future]:
		world.puzzle_completed.connect(func(name: String) -> void: puzzle_completed.emit(name))
		world.portalled.connect(func() -> void: portalled.emit())

func play() -> void: # called when player clicks 'play'
	[$PyraWorld/Past, $PyraWorld/Present, $PyraWorld/Future][current_level].set_birds_start_view()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quick_turn"):
		_on_all_crystals_collected(Vector3.ZERO)
