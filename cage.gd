extends Node3D
class_name Cage

@onready var bars := $Bars.get_children()

func _ready() -> void:
	$Ball/MeshInstance3D.set_surface_override_material(
		0, $Ball/MeshInstance3D.get_active_material(0).duplicate())

func open() -> void:
	print(bars)
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()
	for i in bars.size():
		tween.tween_property(bars[i], "rotation:x", deg_to_rad(-150), 4).set_delay(i * 0.15)

func reset() -> void:
	for bar in bars:
		bar.rotation.x = deg_to_rad(-28)

func get_material() -> StandardMaterial3D:
	return $Ball/MeshInstance3D.get_surface_override_material(0)

func pulse(color: Color) -> void:
	var material: Material = $Ball/MeshInstance3D.get_surface_override_material(0)
	var tween := create_tween()

	material.emission = color
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(material, "emission_energy_multiplier", 1, 0.7)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(material, "emission_energy_multiplier", 0, 0.7)
	await tween.finished
