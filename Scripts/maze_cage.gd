extends Node3D
class_name MazeCage

@export var door: WallSegment

func _find_level() -> Level:
	var n := self as Node
	while n and not (n is Level):
		n = n.get_parent()
	return n

func snap_open() -> void:
	door.snap_open()

func open() -> void:
	var level := _find_level()
	
	var present_maze: MazeCage = level.get_counterpart(self, level.present)
	
	if present_maze:
		present_maze.snap_open()
	
	await door.unfurl()
