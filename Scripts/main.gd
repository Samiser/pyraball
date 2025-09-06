extends Node3D

func _ready() -> void:
	$Player.rotate.connect($World._on_rotation)
	$Player.all_crystals_collected.connect($World._on_all_crystals_collected)
	$World.puzzle_completed.connect($Player.on_puzzle_completed)
	$Music.playing = true
