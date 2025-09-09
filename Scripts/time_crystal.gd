extends Node3D
class_name TimeCrystal

var is_collected: bool = false
signal collected

func _ready() -> void:
	$MapMarker.visible = true

func _animate_collection() -> void:
	$Explosion.emitting = true
	var tween := create_tween()
	tween.tween_property($Sprite3D, "modulate:a", 0, 1.0)
	tween.tween_callback(queue_free)

func _on_body_entered(body: Node3D) -> void:
	if body is Player and not is_collected:
		is_collected = true
		_animate_collection()
		body.collect_crystal()
		collected.emit()
