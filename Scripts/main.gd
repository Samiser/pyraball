extends Node3D

@onready var player: Player = $Player
@onready var menu_camera: Camera3D = $MenuCamera

var game_started: bool = false

func _switch_music(from: AudioStreamPlayer, to: AudioStreamPlayer) -> void:
	var tween := create_tween()
	tween.tween_property(from, "volume_db", -80, 2)
	tween.parallel().tween_property(to, "volume_db", -8, 0.1)

func start() -> void:
	$MainMenu.queue_free()
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property($MenuCamera, "position", Vector3(-18, 74, -58), 4)
	tween.parallel().tween_property($MenuCamera, "rotation_degrees", Vector3(32, -35.5, 0), 4)
	await tween.finished
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($MenuCamera, "global_position", player.camera.global_position, 6)
	tween.parallel().tween_property($MenuCamera, "global_rotation", player.camera.global_rotation, 6)
	tween.parallel().tween_property($MenuCamera, "fov", player.camera.fov, 6)
	tween.parallel().tween_callback(func() -> void: $UI.visible = true; $UI.fade_in()).set_delay(6 - $UI.fade_in_time)
	await tween.finished
	player.camera.current = true

func _ready() -> void:
	menu_camera.position = Vector3(50, 64.5, 88.5)
	menu_camera.rotation_degrees = Vector3(8, -16.8, 0)
	player.rotate.connect($World._on_rotation)
	player.all_crystals_collected.connect($World._on_all_crystals_collected)
	$World.puzzle_completed.connect(player.on_puzzle_completed)
	$Music2.playing = true
	$Music.playing = true
	$World.outside.connect(func(outside: bool) -> void: _switch_music($Music, $Music2) if outside else _switch_music($Music2, $Music))
	$MainMenu.play.connect(start)
	$MainMenu.options.connect(func() -> void: $OptionsMenu.visible = true)
	$OptionsMenu.sensitivity_changed.connect($Player.change_sensitivity)
	$OptionsMenu.invert_changed.connect($Player.change_invert)
	$OptionsMenu.closed.connect(func() -> void: $MainMenu.visible = !game_started)
