extends RigidBody3D

var rolling_force: float = 50.0
@onready var camera_target: Marker3D = $CameraTarget

func _ready() -> void:
	camera_target.top_level = true

func _physics_process(delta: float) -> void:
	camera_target.global_transform.origin = lerp(
		camera_target.global_transform.origin,
		global_transform.origin, 0.1
	)
	
	var input_vector: Vector2 = Input.get_vector("forward", "back", "right", "left")
	angular_velocity += Vector3(input_vector.x, 0, input_vector.y) * rolling_force * delta
