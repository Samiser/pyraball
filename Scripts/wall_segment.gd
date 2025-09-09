extends Node3D

func tween_rotation(new_rotation: Vector3) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tween.tween_property($Wall, "rotation", new_rotation, 1)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		tween_rotation(Vector3(deg_to_rad(-3), 0, 0))

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		tween_rotation(Vector3(0, 0, deg_to_rad(90)))

func _ready() -> void:
	tween_rotation(Vector3(0, 0, deg_to_rad(90)))
