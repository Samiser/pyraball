extends Node3D

@onready var player: Player = $Player
@onready var menu_camera: Camera3D = $MenuCamera

@onready var main_menu := $Menus/MainMenu
@onready var options_menu := $Menus/OptionsMenu
@onready var pause_menu := $Menus/PauseMenu

var current_song: AudioStreamPlayer

var game_started: bool = false

func _switch_music(from: AudioStreamPlayer, to: AudioStreamPlayer, time: float) -> void:
	current_song = to
	var tween := create_tween()
	tween.tween_property(from, "volume_linear", 0, time)
	tween.parallel().tween_property(to, "volume_linear", 0.4, time)

func start() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Menus.start()
	$World.play()
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property($MenuCamera, "position", Vector3(-18, 74, -58), 4)
	tween.parallel().tween_property($MenuCamera, "rotation_degrees", Vector3(32, -35.5, 0), 4)
	tween.parallel().tween_callback(func() -> void: _switch_music($no_drums, $twinkly, 2))
	await tween.finished
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($MenuCamera, "global_position", player.camera.global_position, 6)
	tween.parallel().tween_property($MenuCamera, "global_rotation", player.camera.global_rotation, 6)
	tween.parallel().tween_property($MenuCamera, "fov", player.camera.fov, 6)
	tween.parallel().tween_callback(func() -> void: $UI.visible = true; $UI.fade_in()).set_delay(6 - $UI.fade_in_time)
	tween.parallel().tween_callback(func() -> void: _switch_music($twinkly, $minimal_drums, 8)).set_delay(6 - 4)
	await tween.finished
	player.camera.current = true
	player.game_started = true

func _start_music() -> void:
	$minimal_drums.play()
	$breakbeat.play()
	$no_drums.play()
	$twinkly.play()

func _ready() -> void:
	menu_camera.position = Vector3(50, 64.5, 88.5)
	menu_camera.rotation_degrees = Vector3(8, -16.8, 0)
	
	player.rotate.connect($World._on_rotation)
	player.all_crystals_collected.connect($World._on_all_crystals_collected)
	$World.puzzle_completed.connect(player.on_puzzle_completed)
	$World.outside.connect(func(outside: bool) -> void: _switch_music($minimal_drums, $breakbeat, 2) if outside else _switch_music($breakbeat, $minimal_drums, 2))
	main_menu.play.connect(start)
	options_menu.sensitivity_changed.connect($Player.change_sensitivity)
	options_menu.invert_changed.connect($Player.change_invert)
	$World.game_finished.connect(func() -> void: _switch_music(current_song, $twinkly, 10))

	_start_music()
