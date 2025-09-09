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
#@onready var reflection_cam: Camera3D = $MeshInstance3D/Reflection_Mesh/SubViewport/reflection_cam
#@onready var reflection_mesh: MeshInstance3D = $MeshInstance3D/Reflection_Mesh
#@onready var roll_particles : GPUParticles3D = $roll_particles
@onready var shadow_ray : RayCast3D = $shadow_ray
@onready var shadow_sprite : Sprite3D = $shadow_ray/player_shadow
@onready var dust := $CameraTarget/SpringArm3D/Camera3D/dust_particles
@onready var collider := $CollisionShape3D

@export var jump_sfx : AudioStream
@export var impact_sfx : AudioStream
@export var crystal_pickup_sfx : AudioStream
@onready var sfx_stream : AudioStreamPlayer3D = $sfx_stream
@onready var respawn_sfx : AudioStreamPlayer3D = $respawn_hand/respawn_sfx
@onready var roll_sfx_stream : AudioStreamPlayer3D = $sfx_roll_stream

var past_unlocked: bool = false
var future_unlocked: bool = false

var current_level : Level
var all_crystals_are_collected: bool = false

signal rotate(direction: String, player_position: Vector3, levels_unlocked: int)
signal all_crystals_collected(player_position: Vector3)

var last_linear_velocity: Vector3
var last_angular_velocity: Vector3

var last_safe_pos : Vector3
var is_respawning := false
var respawn_camera := false
@onready var hand_mesh := $respawn_hand
var backup_respawn_points :Array[Vector3]= [
Vector3(-80, 44,-120),
Vector3(80, 44,-120),
Vector3(-50, 44,-44),
Vector3(50, 44,-44),
Vector3(-50, 44,-58),
Vector3(50, 44,-58),
Vector3(0, 44,55)
]
var was_grounded := false
var has_jumped := false
var coyote_timer := 0.0
var respawn_time := 0.0
var is_colliding := false

func _ready() -> void:
	$MapMarker.visible = true
		
	camera_target.top_level = true
	floor_check.top_level = true
	#roll_particles.top_level = true
	shadow_ray.top_level = true
	shadow_sprite.top_level = true
	hand_mesh.top_level = true
	
	spring_arm.add_excluded_object(self)

func on_puzzle_completed(name: String) -> void:
	if name == "PastSundial":
		past_unlocked = true
	elif name == "FutureSundial":
		future_unlocked = true

func _rotate(direction: String) -> void:
	last_linear_velocity = linear_velocity
	last_angular_velocity = angular_velocity
	freeze = true
	collider.disabled = true
	var levels_unlocked: int = 3 if future_unlocked and past_unlocked else 2
	rotate.emit(direction, global_position, levels_unlocked)

func rotation_completed(old_position: Vector3) -> void:
	freeze = false
	collider.disabled = false
	linear_velocity = last_linear_velocity
	angular_velocity = last_angular_velocity

func _tween_size(new_scale: float, duration: float = 2.0) -> Tween:
	var t := create_tween().parallel()
	t.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	var mesh: SphereMesh = $MeshInstance3D.mesh
	var shape: SphereShape3D = $CollisionShape3D.shape
	var arm := spring_arm

	t.tween_property(mesh, "radius", new_scale, duration)
	t.parallel().tween_property(mesh, "height", new_scale * 2.0, duration)
	t.parallel().tween_property(shape, "radius", new_scale, duration)
	t.parallel().tween_property(arm, "spring_length", 6.0 * new_scale, duration)
	t.parallel().tween_property(arm, "position:y", 2.0 * new_scale, duration)
	
	return t

func set_new_scale(new_scale: float, level: int) -> void:
	_tween_size(new_scale)
	$FloorCheck.target_position.y = -1.25 * new_scale
	dust.emitting = false
	$light.hide()
	constant_force = Vector3.ZERO
	match level:
		0: # past/small
			# mass = 0.5
			rolling_force = 64.0
			jump_force = 5.8
			air_control_force = 468.0
			shadow_sprite.pixel_size = 0.0004
			shadow_sprite.material_override.distance_fade_min_distance = 1.4
			shadow_sprite.material_override.distance_fade_max_distance = 8.0
			if global_position.z < -60:
				add_constant_force(Vector3.LEFT)
			dust.emitting = true
		1: # present/medium
			# mass = 4.0
			rolling_force = 32.0
			jump_force = 8.4
			air_control_force = 700.0
			shadow_sprite.pixel_size = 0.0012
			shadow_sprite.material_override.distance_fade_min_distance = 4.4
			shadow_sprite.material_override.distance_fade_max_distance = 8.0
			$light.show()
		2: # future/big
			# mass = 20.0
			rolling_force = 10.0
			jump_force = 15.0
			air_control_force = 512.0
			shadow_sprite.pixel_size = 0.007
			shadow_sprite.material_override.distance_fade_min_distance = 22.0
			shadow_sprite.material_override.distance_fade_max_distance = 32.0

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
	elif event.is_action_pressed("rotate_left") and not all_crystals_are_collected and past_unlocked:
		_rotate("left")
	elif event.is_action_pressed("rotate_right") and not all_crystals_are_collected and past_unlocked:
		_rotate("right")
	elif event.is_action_pressed("unlock_all"):
		past_unlocked = true
		future_unlocked = true
	elif event.is_action_pressed("respawn"):
		respawn_player()

func _unhandled_input(event: InputEvent) -> void:
	if is_respawning:
		return
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation.x = clampf(spring_arm.rotation.x, -tilt_limit, tilt_limit)
		spring_arm.rotation.y += -event.relative.x * mouse_sensitivity

func _process(delta: float) -> void:
	if respawn_camera:
		var new_rot := camera.transform.looking_at(transform.origin, Vector3.UP)
		camera.transform = camera.transform.interpolate_with(new_rot, 4.0 * delta)
	else:
		if Input.is_action_just_pressed("teleport"):
			global_position += -camera.global_basis.z * 12.0
		
func _physics_process(delta: float) -> void:
	camera_target.global_transform.origin = lerp(
		camera_target.global_transform.origin,
		global_transform.origin, 0.2
	)
	
	if jump_force == 5.8: # silly way of checking if player is da small ball, for da wind
		if global_position.z < -60:
			angular_velocity += Vector3.LEFT * delta
	
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
	else:
		if global_position.y > 42.0:
			last_safe_pos = global_position # used for respawning
	
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
	roll_sfx_stream.stream_paused = !is_colliding
	var roll_sfx_pitch := clampf(speed * 0.1, 0.0001, 4.0)
	roll_sfx_stream.pitch_scale = roll_sfx_pitch
	
	# speedy ball particles
	#roll_particles.emitting = floor_check.is_colliding() && speed > 12.0
	#roll_particles.global_position = global_position - Vector3(0.0, 0.6, 0.0)
	
	# fake refraction stuff
	#reflection_cam.global_position = global_position
	#reflection_cam.global_rotation = camera.global_rotation
	
	# blob shadow
	shadow_ray.global_position = global_position
	var shadow_hitting : bool = shadow_ray.is_colliding()
	shadow_sprite.visible = shadow_hitting
	if shadow_hitting:
		shadow_sprite.global_position = shadow_ray.get_collision_point() + shadow_ray.get_collision_normal() * 0.01
		if !shadow_ray.get_collision_normal().is_equal_approx(Vector3.UP):
			shadow_sprite.look_at(shadow_ray.get_collision_point() + shadow_ray.get_collision_normal())
		else:
			shadow_sprite.rotation_degrees = Vector3(90.0, 0.0, 0.0)

func respawn_player() -> void:
	if is_respawning:
		return
		
	is_respawning = true
	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
		
	hand_mesh.visible = true
	hand_mesh.scale = Vector3.ZERO
	hand_mesh.position = global_position + Vector3.UP * 10.0
	hand_mesh.global_rotation_degrees.z = -90.0
	
	var fall_pos := global_position
	var safe_height := last_safe_pos.y
	last_safe_pos += (last_safe_pos - fall_pos).normalized() * 4.0
	last_safe_pos.y = safe_height
	
	if (Time.get_ticks_msec() - respawn_time) < 4000:
		var closest_dist := 99999
		var new_pos := Vector3.ZERO
		for pos in backup_respawn_points:
			var dist := last_safe_pos.distance_to(pos)
			if dist < closest_dist:
				new_pos = pos
				closest_dist = dist
		last_safe_pos = new_pos
	respawn_sfx.play()
	
	# hand comes down
	var tween := get_tree().create_tween()
	tween.tween_property(hand_mesh, "scale", Vector3.ONE * $MeshInstance3D.mesh.radius * 2.4, 0.6)
	tween.tween_property(hand_mesh, "global_position", global_position, 1.0)
	tween.parallel().tween_property(hand_mesh, "global_rotation_degrees:z", 0.0, 1.0)
	
	var original_cam_trans := camera.transform
	camera.reparent(get_tree().root)
	respawn_camera = true # smooth look-at logic is in process
	
	# hand moves up
	tween.tween_property(hand_mesh, "global_position:y", last_safe_pos.y + 10.0, 2.0)
	tween.parallel().tween_property(hand_mesh, "global_rotation_degrees:z", -45.0, 2.0)
	tween.parallel().tween_property(self, "global_position:y", last_safe_pos.y + 10.0, 2.0)
	
	# hand moves to drop pos
	await tween.finished
	tween = get_tree().create_tween()
	camera.global_position = last_safe_pos + (Vector3.LEFT * 4.0 + Vector3.UP * 6.0) * $MeshInstance3D.mesh.radius
	tween.tween_property(hand_mesh, "global_position", last_safe_pos, 2.0)
	tween.parallel().tween_property(self, "global_position", last_safe_pos, 2.0)
	
	# hand leaves
	tween.tween_property(hand_mesh, "global_position", last_safe_pos + Vector3.UP * 10.0, 1.0)
	tween.parallel().tween_property(hand_mesh, "global_rotation_degrees:z", -90.0, 1.0)
	tween.tween_property(hand_mesh, "scale", Vector3.ZERO, 0.6)

	await tween.finished
	
	respawn_sfx.stop()
	
	# camera move back to player view
	respawn_camera = false
	camera.reparent(spring_arm)
	tween = get_tree().create_tween()
	tween.parallel().tween_property(camera, "transform", original_cam_trans, 0.6)

	await tween.finished
	
	hand_mesh.visible = false
	freeze = false
	respawn_time = Time.get_ticks_msec()
	is_respawning = false


func _on_body_entered(body: Node) -> void:
	is_colliding = true
	if floor_check.is_colliding():
		was_grounded = false
		has_jumped = false
	if !sfx_stream.playing && linear_velocity.length() > 1.2:
		sfx_stream.pitch_scale = randf_range(0.8, 1.2)
		sfx_stream.stream = impact_sfx
		sfx_stream.play()

func _on_body_exited(body: Node) -> void:
	is_colliding = false
