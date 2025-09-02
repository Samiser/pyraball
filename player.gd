extends RigidBody3D

var rolling_force: float = 50.0

@export_range(0.0, 0.1) var mouse_sensitivity: float = 0.01
@export var tilt_limit: float = deg_to_rad(75)

@onready var floor_check: RayCast3D = $FloorCheck
@onready var camera_target: Marker3D = $CameraTarget
@onready var spring_arm: SpringArm3D = $CameraTarget/SpringArm3D

func _ready() -> void:
	camera_target.top_level = true
	floor_check.top_level = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation.x = clampf(spring_arm.rotation.x, -tilt_limit, tilt_limit)
		spring_arm.rotation.y += -event.relative.x * mouse_sensitivity

func _physics_process(delta: float) -> void:
	camera_target.global_transform.origin = lerp(
		camera_target.global_transform.origin,
		global_transform.origin, 0.1
	)
	
	floor_check.global_transform.origin = global_transform.origin
	
	var input_vector: Vector2 = Input.get_vector("forward", "back", "right", "left")
	angular_velocity += Vector3(input_vector.x, 0, input_vector.y).rotated(Vector3.UP, spring_arm.rotation.y) * rolling_force * delta

	if Input.is_action_just_pressed("jump") and floor_check.is_colliding():
		apply_impulse(Vector3.UP * mass * 10)
