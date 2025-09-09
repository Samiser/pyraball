extends Node3D

func _switch_music(from: AudioStreamPlayer, to: AudioStreamPlayer) -> void:
	var tween := create_tween()
	tween.tween_property(from, "volume_db", -80, 2)
	tween.parallel().tween_property(to, "volume_db", -8, 0.1)

func _ready() -> void:
	$Player.rotate.connect($World._on_rotation)
	$Player.all_crystals_collected.connect($World._on_all_crystals_collected)
	$World.puzzle_completed.connect($Player.on_puzzle_completed)
	$Music2.playing = true
	$Music.playing = true
	$World.outside.connect(func(outside: bool) -> void: _switch_music($Music, $Music2) if outside else _switch_music($Music2, $Music))
