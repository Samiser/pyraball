extends AnimatableBody3D

@export var clockwise: bool = true

func _process(delta: float) -> void:
	rotation.y += deg_to_rad(20 * delta) * (1 if clockwise else -1)
