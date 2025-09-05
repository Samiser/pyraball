extends Node3D
class_name Sundial

var original_marker_color: Color = Color.WHITE

func _process(delta: float) -> void:
	$LightPivot.rotate_y(-0.3 * delta)

func get_target_position() -> Vector3:
	return $TargetSphere.global_position

func _tween_color(marker: Pyramid, new_color: Color) -> void:
	var tween := create_tween()
	tween.tween_property(marker, "color", new_color, 0.5)

func _on_shadow_area_entered(area: Area3D) -> void:
	if area.get_parent().is_in_group("clock_marker"):
		var marker: Pyramid = area.get_parent()
		original_marker_color = marker.color
		_tween_color(marker, Color.CYAN)

func _on_shadow_area_exited(area: Area3D) -> void:
	if area.get_parent().is_in_group("clock_marker"):
		var marker: Pyramid = area.get_parent()
		_tween_color(marker, original_marker_color)
