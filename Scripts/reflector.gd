extends Node3D
class_name Reflector

@export var sundial: Sundial
@export var button: TriangleButton
@export var light_shaft: MeshInstance3D

@onready var mirror_mesh := $MeshInstance3D

var facing_sundial: bool = false

func _face_sundial(_button: TriangleButton) -> void:
	if facing_sundial:
		return
	
	if not sundial:
		printerr("No sundial assigned to reflector node: ", self)
		return
	
	facing_sundial = true
	var target_position := sundial.get_target_position()
	var direction: Vector3 = (target_position - global_position)
	
	var target_xf := Transform3D(Basis.IDENTITY, global_position).looking_at(target_position)
	var from_q: Quaternion = self.global_transform.basis.get_rotation_quaternion()
	var to_q: Quaternion = target_xf.basis.get_rotation_quaternion()

	var tween := create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(
		func(t: float) -> void:
			var q := from_q.slerp(to_q, t)
			var xf := self.global_transform
			xf.basis = Basis(q)
			self.global_transform = xf
	, 0.0, 1.0, 3)
	tween.parallel().tween_property(mirror_mesh.get_surface_override_material(0), "emission_energy_multiplier", 5.5, 3)
	#light_shaft.visible = true
	tween.tween_property(light_shaft.get_surface_override_material(0), "shader_parameter/far_fade_end", 100.0, 1)

func _ready() -> void:
	mirror_mesh.set_surface_override_material(
		0,
		mirror_mesh.get_active_material(0).duplicate()
	)
	
	light_shaft.set_surface_override_material(
		0,
		light_shaft.get_active_material(0).duplicate()
	)
	
	light_shaft.visible = false
	
	print(light_shaft.visible)
	
	if button:
		button.pressed.connect(_face_sundial)
