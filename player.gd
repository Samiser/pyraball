extends RigidBody3D
class_name Player

var rolling_force: float = 60.0

@export_range(0.0, 0.1) var mouse_sensitivity: float = 0.01
@export var tilt_limit: float = deg_to_rad(75)

@export_range(1.0, 179.0) var base_fov: float = 75.0
@export_range(1.0, 179.0) var max_fov: float = 110.0
@export var max_speed: float = 30.0
@export var smooth: float = 8.0

@onready var floor_check: RayCast3D = $FloorCheck
@onready var camera_target: Marker3D = $CameraTarget
@onready var spring_arm: SpringArm3D = $CameraTarget/SpringArm3D
@onready var camera: Camera3D = $CameraTarget/SpringArm3D/Camera3D
@onready var reflection_cam: Camera3D = $MeshInstance3D/Reflection_Mesh/SubViewport/reflection_cam
@onready var reflection_mesh: MeshInstance3D = $MeshInstance3D/Reflection_Mesh

signal rotate(direction: String, player_position: Vector3)

var last_linear_velocity: Vector3
var last_angular_velocity: Vector3

func _ready() -> void:
	camera_target.top_level = true
	floor_check.top_level = true
	#reflection_mesh.top_level = true

func _rotate(direction: String) -> void:
	last_linear_velocity = linear_velocity
	last_angular_velocity = angular_velocity
	freeze = true
	rotate.emit(direction, global_position)

func rotation_completed(old_position: Vector3) -> void:
	freeze = false
	linear_velocity = last_linear_velocity
	angular_velocity = last_angular_velocity

func set_new_scale(new_scale: float) -> void:
	$MeshInstance3D.mesh.radius = new_scale
	$MeshInstance3D.mesh.height = new_scale * 2
	$CollisionShape3D.shape.radius = new_scale
	spring_arm.spring_length = 6.0 * new_scale
	spring_arm.transform.origin.y = 2.0 * new_scale
	$FloorCheck.target_position.y = -1.25 * new_scale
	rolling_force = (1.0 / new_scale) * 30

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("rotate_left"):
		_rotate("left")
	elif event.is_action_pressed("rotate_right"):
		_rotate("right")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation.x = clampf(spring_arm.rotation.x, -tilt_limit, tilt_limit)
		spring_arm.rotation.y += -event.relative.x * mouse_sensitivity

func _physics_process(delta: float) -> void:
	camera_target.global_transform.origin = lerp(
		camera_target.global_transform.origin,
		global_transform.origin, 0.2
	)
	
	var v := linear_velocity
	v.y = 0.0
	var speed: float = clamp(v.length(), 0, max_speed)
	var t := speed / max_speed
	var target_fov: float = lerp(base_fov, max_fov, t)

	var alpha := 1.0 - exp(-smooth * delta)
	camera.fov = lerp(camera.fov, target_fov, alpha)
	
	floor_check.global_transform.origin = global_transform.origin
	
	var input_vector: Vector2 = Input.get_vector("forward", "back", "right", "left")
	angular_velocity += Vector3(input_vector.x, 0, input_vector.y).rotated(Vector3.UP, spring_arm.rotation.y) * rolling_force * delta
	
	if Input.is_action_just_pressed("jump") and floor_check.is_colliding():
		apply_impulse(Vector3.UP * mass * 10)
	
	reflection_cam.global_position = global_position
	reflection_cam.global_rotation = camera.global_rotation
	#reflection_mesh.global_position = global_position
