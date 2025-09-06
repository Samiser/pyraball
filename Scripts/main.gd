extends Node3D

func _switch_music() -> void:
	var tween := create_tween()
	tween.tween_property($Music, "volume_db", -80, 2)
	tween.parallel().tween_property($Music2, "volume_db", -8, 0.1)

func _ready() -> void:
	$Player.rotate.connect($World._on_rotation)
	$Player.all_crystals_collected.connect($World._on_all_crystals_collected)
	$World.puzzle_completed.connect($Player.on_puzzle_completed)
	$Music2.playing = true
	$Music.playing = true
	$World.portalled.connect(_switch_music)
