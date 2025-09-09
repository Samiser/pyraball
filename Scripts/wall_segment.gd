extends Node3D
class_name WallSegment

@export var flipping: bool = true 

func tween_rotation(new_rotation: Vector3) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tween.tween_property($Wall, "rotation", new_rotation, 1)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player and flipping:
		tween_rotation(Vector3(deg_to_rad(-3), 0, 0))

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player and flipping:
		tween_rotation(Vector3(0, 0, deg_to_rad(90)))

func unfurl() -> void:
	var tween := create_tween()
	var bars := $Wall.get_children()
	var right_bars := bars.slice(0, 6)
	var left_bars := bars.slice(6, 12)
	for bar: Pyramid in right_bars:
		tween.parallel().tween_property(bar, "rotation_degrees", Vector3(-85.8, -270., 0.), 2).set_delay(0.1)
	for bar: Pyramid in left_bars:
		tween.parallel().tween_property(bar, "rotation_degrees", Vector3(-85.8, -45., 135.), 2).set_delay(0.1)
	await tween.finished

func _ready() -> void:
	if flipping:
		tween_rotation(Vector3(0, 0, deg_to_rad(90)))
