extends Node3D

func _ready() -> void:
	$Player.rotate.connect($World._on_rotation)
