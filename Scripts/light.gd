extends Node3D

func _process(delta: float) -> void:
	$Balls.rotation.y += deg_to_rad(20 * delta)
	$Balls2.rotation.y -= deg_to_rad(20 * delta)

func _tween_light(on: bool) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_QUAD)
	if on:
		$OmniLight3D.visible = true
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property($OmniLight3D, "light_energy", 7, 2)
	else:
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property($OmniLight3D, "light_energy", 0, 2)
		await tween.finished
		$OmniLight3D.visible = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		_tween_light(true)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		_tween_light(false)

func _ready() -> void:
	$OmniLight3D.visible = false
	$OmniLight3D.light_energy = 0
