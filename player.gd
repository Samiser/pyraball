extends RigidBody3D

var rolling_force: float = 50.0
@onready var floor_check: RayCast3D = $FloorCheck
@onready var camera_target: Marker3D = $CameraTarget

func _ready() -> void:
	camera_target.top_level = true
	floor_check.top_level = true

func _physics_process(delta: float) -> void:
	camera_target.global_transform.origin = lerp(
		camera_target.global_transform.origin,
		global_transform.origin, 0.1
	)
	
	floor_check.global_transform.origin = global_transform.origin
	
	var input_vector: Vector2 = Input.get_vector("forward", "back", "right", "left")
	angular_velocity += Vector3(input_vector.x, 0, input_vector.y) * rolling_force * delta

	if Input.is_action_just_pressed("jump") and floor_check.is_colliding():
		apply_impulse(Vector3.UP * 10)
