extends Node3D

var collected: bool = false

func _animate_collection() -> void:
	$Gradual.emitting = false
	$Explosion.emitting = true
	var tween := create_tween()
	tween.tween_property($Sprite3D, "modulate:a", 0, 1.0)
	tween.parallel().tween_property($OmniLight3D, "light_energy", 0, 1.0)
	tween.tween_callback(queue_free)

func _on_body_entered(body: Node3D) -> void:
	if body is Player and not collected:
		collected = true
		_animate_collection()
		body.collect_crystal()
