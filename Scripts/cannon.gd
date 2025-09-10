extends Node3D

@export_range (-360.0, 360.0) var dir_y_degrees : float
@export_range (-80.0, 80.0) var dir_x_degrees : float = 40.0
@export var force : float = 40
@onready var barrel :Node3D= $barrel
@onready var fire_spot :Node3D= $barrel/fire_spot
@onready var sfx_stream :AudioStreamPlayer3D= $turn_sfx_stream
@export var fire_sfx : AudioStreamMP3
@export var turn_sfx : AudioStreamMP3

var start_dir : float
var firing := false

func _ready() -> void:
	start_dir = rotation_degrees.y

func _on_static_body_3d_body_entered(body: Node3D) -> void:
	if firing:
		return
		
	if body is Player:
		firing = true
		
		var rb : RigidBody3D = body as RigidBody3D
		rb.freeze = true
			
		var tween := get_tree().create_tween()
		tween.tween_property(body, "global_position", $barrel/fire_spot.global_position, 0.4)
		await tween.finished
		body.reparent(fire_spot)
		tween = get_tree().create_tween()
		sfx_stream.stream = turn_sfx
		sfx_stream.play()
		tween.tween_property(self, "rotation_degrees:y", wrapf(dir_y_degrees, 0.0, 360.0), 1.2)
		tween.tween_property(barrel, "rotation_degrees:x", 90.0 + -dir_x_degrees, 1.4)
		
		await tween.finished
		sfx_stream.stop()
		await get_tree().create_timer(0.6).timeout
		
		sfx_stream.stream = fire_sfx
		sfx_stream.play()
		
		body.reparent(get_tree().root)
		rb.linear_velocity = Vector3.ZERO
		rb.freeze = false
		rb.apply_impulse(-$barrel/fire_spot.global_transform.basis.z.normalized() * force)
		
		tween = get_tree().create_tween()
		tween.tween_property(self, "rotation_degrees:y", start_dir, 2.0)
		tween.tween_property(barrel, "rotation_degrees:x", 90.0, 2.0)
		await tween.finished
		
		firing = false
