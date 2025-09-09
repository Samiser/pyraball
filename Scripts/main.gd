extends Node3D

@onready var player: Player = $Player

func _switch_music(from: AudioStreamPlayer, to: AudioStreamPlayer) -> void:
	var tween := create_tween()
	tween.tween_property(from, "volume_db", -80, 2)
	tween.parallel().tween_property(to, "volume_db", -8, 0.1)

func start() -> void:
	$MainMenu.queue_free()
	var tween := create_tween()
	tween.tween_property($MenuCamera, "global_position", player.camera.global_position, 3)
	tween.parallel().tween_property($MenuCamera, "global_rotation", player.camera.global_rotation, 3)
	tween.parallel().tween_property($MenuCamera, "fov", player.camera.fov, 3)
	await tween.finished
	player.camera.current = true
	$UI.visible = true

func _ready() -> void:
	player.rotate.connect($World._on_rotation)
	player.all_crystals_collected.connect($World._on_all_crystals_collected)
	$World.puzzle_completed.connect(player.on_puzzle_completed)
	$Music2.playing = true
	$Music.playing = true
	$World.outside.connect(func(outside: bool) -> void: _switch_music($Music, $Music2) if outside else _switch_music($Music2, $Music))
	$MainMenu.play.connect(start)
