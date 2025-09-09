extends Node3D
class_name MazeCage

@export var door: WallSegment

func open() -> void:
	await door.unfurl()
