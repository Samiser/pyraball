extends Node3D

func _process(delta: float) -> void:
	$Balls.rotation.y += deg_to_rad(20 * delta)
	$Balls2.rotation.y -= deg_to_rad(20 * delta)

func _on_area_3d_body_entered(body: Node3D) -> void:
	$OmniLight3D.visible = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	$OmniLight3D.visible = false

func _ready() -> void:
	$OmniLight3D.visible = false
