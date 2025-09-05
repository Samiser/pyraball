extends Node3D

@onready var portal_cam := $SubViewport/Camera3D
@export var dest : Node3D
var camera : Node3D

func _ready() -> void:
	portal_cam.global_position = dest.global_position
	camera = get_viewport().get_camera_3d()

func _process(delta: float) -> void:
	portal_cam.global_rotation = camera.global_rotation


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		body.global_position = dest.global_position
