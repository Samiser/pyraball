extends Node3D
@export var dest : Node3D
@onready var mesh : MeshInstance3D = $MeshInstance3D
var time := 0.0
signal portalled

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		body.global_position = dest.global_position
		emit_signal("portalled")

func _process(delta: float) -> void:
	time += delta
	mesh.rotate_y(4.0 * delta)
	mesh.rotate_z(1.0 * delta)
	mesh.rotate_x(1.0 * delta)
	var scale_sin := 1.0 + sin(2.0 * time) * 0.5
	scale = Vector3.ONE * scale_sin
