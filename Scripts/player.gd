extends RigidBody3D
class_name Player

var rolling_force: float = 50.0
var jump_force : float = 20.0
var air_control_force : float = 256.0

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
@onready var roll_particles : GPUParticles3D = $roll_particles
@onready var shadow_ray : RayCast3D = $shadow_ray
@onready var shadow_sprite : Sprite3D = $shadow_ray/player_shadow

@export var jump_sfx : AudioStream
@export var impact_sfx : AudioStream
@export var crystal_pickup_sfx : AudioStream
@onready var sfx_stream : AudioStreamPlayer3D = $sfx_stream
@onready var roll_sfx_stream : AudioStreamPlayer3D = $sfx_roll_stream

var current_level : Level
var all_crystals_are_collected: bool = false

signal rotate(direction: String, player_position: Vector3)
signal all_crystals_collected(player_position: Vector3)

var last_linear_velocity: Vector3
var last_angular_velocity: Vector3

var was_grounded := false
var has_jumped := false
var coyote_timer := 0.0

func _ready() -> void:
	$MapMarker.visible = true
		
	camera_target.top_level = true
	floor_check.top_level = true
	roll_particles.top_level = true
	shadow_ray.top_level = true
	shadow_sprite.top_level = true

func _rotate(direction: String) -> void:
	last_linear_velocity = linear_velocity
	last_angular_velocity = angular_velocity
	freeze = true
	rotate.emit(direction, global_position)

func rotation_completed(old_position: Vector3) -> void:
	freeze = false
	linear_velocity = last_linear_velocity
	angular_velocity = last_angular_velocity

func set_new_scale(new_scale: float, level: int) -> void:
	$MeshInstance3D.mesh.radius = new_scale
	$MeshInstance3D.mesh.height = new_scale * 2
	$MeshInstance3D/Reflection_Mesh.mesh.radius = new_scale * 0.95
	$MeshInstance3D/Reflection_Mesh.mesh.height = new_scale * 2 * 0.95
	$CollisionShape3D.shape.radius = new_scale
	spring_arm.spring_length = 6.0 * new_scale
	spring_arm.transform.origin.y = 2.0 * new_scale
	$FloorCheck.target_position.y = -1.25 * new_scale

	match level:
		0: # past/small
			mass = 0.5
			rolling_force = 42.0
			jump_force = 2.8
			air_control_force = 128.0
		1: # present/medium
			mass = 4.0
			rolling_force = 40.0
			jump_force = 34.0
			air_control_force = 1124.0
		2: # future/big
			mass = 20.0
			rolling_force = 10.0
			jump_force = 80.0
			air_control_force = 512.0

func collect_crystal() -> void:
	var crystals: Array = get_tree().get_nodes_in_group("time_crystal").filter(
		func(crystal: TimeCrystal) -> bool: return !crystal.is_collected
	)
	
	sfx_stream.pitch_scale = 1.0
	sfx_stream.stream = crystal_pickup_sfx
	sfx_stream.play()
	
	if crystals.size() == 0:
		all_crystals_collected.emit(position)
		all_crystals_are_collected = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("rotate_left") and not all_crystals_are_collected:
		_rotate("left")
	elif event.is_action_pressed("rotate_right") and not all_crystals_are_collected:
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
	if !floor_check.is_colliding(): # slow spin force while airborne
		input_vector *= 0.4
	angular_velocity += Vector3(input_vector.x, 0, input_vector.y).rotated(Vector3.UP, spring_arm.rotation.y) * rolling_force * delta
	
	# air control
	if !floor_check.is_colliding():
		var air_control_vector := Vector3(-input_vector.y, 0, input_vector.x).rotated(Vector3.UP, spring_arm.rotation.y)
		apply_force(air_control_vector * air_control_force * delta)
		if !was_grounded:
			coyote_timer = 0.2
			was_grounded = true
		coyote_timer -= delta
	
	if Input.is_action_just_pressed("jump") and (floor_check.is_colliding() || (coyote_timer > 0.0 and !has_jumped)):
		apply_impulse(Vector3.UP * jump_force)
		sfx_stream.pitch_scale = 1.0
		sfx_stream.stream = jump_sfx
		sfx_stream.play()
		has_jumped = true
	
	# audio stuff
	roll_sfx_stream.stream_paused = !floor_check.is_colliding()
	var roll_sfx_pitch := clampf(speed * 0.1, 0.0001, 4.0)
	roll_sfx_stream.pitch_scale = roll_sfx_pitch
	
	roll_particles.emitting = floor_check.is_colliding() && speed > 12.0
	roll_particles.global_position = global_position - Vector3(0.0, 0.6, 0.0)
	
	# fake refraction stuff
	reflection_cam.global_position = global_position
	reflection_cam.global_rotation = camera.global_rotation
	
	# blob shadow
	shadow_ray.global_position = global_position
	if shadow_ray.is_colliding():
		shadow_sprite.global_position = shadow_ray.get_collision_point() + shadow_ray.get_collision_normal() * 0.01
		shadow_sprite.look_at(shadow_ray.get_collision_point() + shadow_ray.get_collision_normal())

func _on_body_entered(body: Node) -> void:
	if floor_check.is_colliding():
		was_grounded = false
		has_jumped = false
	if linear_velocity.length() > 0.4:
		sfx_stream.pitch_scale = randf_range(0.8, 1.2)
		sfx_stream.stream = impact_sfx
		sfx_stream.play()
