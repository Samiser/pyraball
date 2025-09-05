extends Node3D

@export var sundial: Sundial
@export var button: TriangleButton

var facing_sundial: bool = false

func _face_sundial(_button: TriangleButton) -> void:
	if facing_sundial:
		return
	
	if not sundial:
		printerr("No sundial assigned to reflector node: ", self)
		return
	
	facing_sundial = true
	var target_position := sundial.get_target_position()
	var direction: Vector3 = (target_position - position)
	
	var target_xf := Transform3D(Basis.IDENTITY, position).looking_at(target_position)
	var from_q: Quaternion = self.global_transform.basis.get_rotation_quaternion()
	var to_q: Quaternion = target_xf.basis.get_rotation_quaternion()

	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(
		func(t: float) -> void:
			var q := from_q.slerp(to_q, t)
			var xf := self.global_transform
			xf.basis = Basis(q)
			self.global_transform = xf
	, 0.0, 1.0, 5)

func _ready() -> void:
	if button:
		button.pressed.connect(_face_sundial)
