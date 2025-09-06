extends Node3D

@export var direction : Vector2
@export var force : float = 40
@onready var barrel :Node3D= $barrel

var starting_y : float
var firing := false

func _ready() -> void:
	starting_y = rotation_degrees.y

func _on_static_body_3d_body_entered(body: Node3D) -> void:
	if firing:
		return
		
	if body is Player:
		firing = true
		
		var rb : RigidBody3D = body as RigidBody3D
		rb.freeze = true
		
		var tween := get_tree().create_tween()

		tween.tween_property(body, "global_position", barrel.global_position + barrel.global_basis.z * 2.0, 1.0)
		tween.parallel().tween_property(self, "rotation_degrees:y", direction.y, 2.0)
		tween.parallel().tween_property(barrel, "rotation_degrees:x", -direction.x, 2.0)

		await tween.finished
		await get_tree().create_timer(0.8).timeout
		
		rb.linear_velocity = Vector3.ZERO
		rb.freeze = false
		rb.apply_impulse(barrel.global_transform.basis.z * force)
		
		tween = get_tree().create_tween()
		tween.tween_property(self, "rotation_degrees:y", starting_y, 2.0)
		tween.tween_property(barrel, "rotation_degrees:x", 90.0, 2.0)
		await tween.finished
		
		firing = false
