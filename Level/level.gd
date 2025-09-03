@tool
extends Node3D

var levels: Array[PackedScene] = [
	preload("res://Meshes/level_past.fbx"),
	preload("res://Meshes/level_present.fbx"),
	preload("res://Meshes/level_future.fbx"),
]

@export_enum("Past", "Present", "Future")
var selected_level: int = 0:
	set(value):
		selected_level = value
		_update_visibility()

func _update_visibility() -> void:
	for child in get_children():
		if child.is_in_group("level"):
			child.queue_free()
	
	var instance := levels[selected_level].instantiate()
	instance.add_to_group("level")
	add_child(instance)

func _ready() -> void:
	_update_visibility()
