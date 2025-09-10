extends Node3D
class_name TimeCrystal

var is_collected: bool = false
signal collected

func _ready() -> void:
	$MapMarker.visible = true
	$MapMarker.scale *= 1.0 / scale.length()
	$MapMarker.global_position.y = 100.0

func _animate_collection() -> void:
	$Gradual.emitting = false
	$Explosion.emitting = true
	$Sprite3D.visible = false
	$Sprite3D2.visible = false
	
	await $Explosion.finished
	self.queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body is Player and not is_collected:
		is_collected = true
		_animate_collection()
		body.collect_crystal()
		collected.emit()
