@tool
extends AnimatableBody3D
class_name Pyramid

@export_range(0.01, 1024.0, 0.01) var base_size: float = 2.0 : set = _set_base_size
@export_range(0.01, 1024.0, 0.01) var height: float = 2.0     : set = _set_height
@export var color: Color = Color(1.0, 0.6, 0.2, 1.0)          : set = _set_color
@export var smooth_shading: bool = false : set = _set_smooth
@export var double_sided: bool = false   : set = _set_double_sided
@export var generate_uvs: bool = true    : set = _set_generate_uvs
@export_enum("Convex:0", "Trimesh:1") var collision_type: int = 0 : set = _set_collision_type
@export var collision_layer_override: int = 1 : set = _set_collision_layer
@export var collision_mask_override: int = 1  : set = _set_collision_mask
@export var rebuild_now: bool = false : set = _force_rebuild

var _mesh_instance: MeshInstance3D
var _shape_node: CollisionShape3D
var _mat: StandardMaterial3D
var _base_size := 2.0
var _height := 2.0
var _smooth_shading := false
var _double_sided := false
var _generate_uvs := true

func _enter_tree() -> void:
	_ensure_children()
	_rebuild_all()

func _ready() -> void:
	sync_to_physics = false
	if Engine.is_editor_hint():
		_rebuild_all()

func _set_base_size(v: float) -> void: _base_size = max(0.01, v); base_size = _base_size; _rebuild_all()
func _set_height(v: float) -> void: _height = max(0.01, v); height = _height; _rebuild_all()
func _set_color(c: Color) -> void: color = c; if _mat: _mat.albedo_color = c; _update_mesh_only()
func _set_smooth(v: bool) -> void: _smooth_shading = v; smooth_shading = v; _rebuild_all()
func _set_double_sided(v: bool) -> void:
	_double_sided = v; double_sided = v
	if _mat: _mat.cull_mode = BaseMaterial3D.CULL_DISABLED if v else BaseMaterial3D.CULL_BACK
	_update_mesh_only()
func _set_generate_uvs(v: bool) -> void: _generate_uvs = v; generate_uvs = v; _rebuild_all()
func _set_collision_type(v: int) -> void: collision_type = v; _rebuild_collision()
func _set_collision_layer(v: int) -> void: collision_layer_override = v; collision_layer = v
func _set_collision_mask(v: int) -> void: collision_mask_override = v; collision_mask = v
func _force_rebuild(v: bool) -> void: rebuild_now = false; _rebuild_all()

func _ensure_children() -> void:
	_mesh_instance = get_node_or_null("Mesh") as MeshInstance3D
	if _mesh_instance == null:
		_mesh_instance = MeshInstance3D.new()
		_mesh_instance.name = "Mesh"
		add_child(_mesh_instance, true)
	_shape_node = get_node_or_null("CollisionShape3D") as CollisionShape3D
	if _shape_node == null:
		_shape_node = CollisionShape3D.new()
		_shape_node.name = "CollisionShape3D"
		add_child(_shape_node, true)
	if _mat == null:
		_mat = StandardMaterial3D.new()
		_mat.albedo_color = color
		_mat.cull_mode = BaseMaterial3D.CULL_DISABLED if _double_sided else BaseMaterial3D.CULL_BACK

func _rebuild_all() -> void:
	if !is_inside_tree(): return
	_ensure_children()
	var mesh := _build_pyramid_mesh()
	_mesh_instance.mesh = mesh
	_mesh_instance.material_override = _mat
	_rebuild_collision(mesh)

func _update_mesh_only() -> void:
	if _mesh_instance: _mesh_instance.material_override = _mat

func _build_pyramid_mesh() -> ArrayMesh:
	var half := _base_size * 0.5
	var v0 := Vector3(-half, 0.0, -half)
	var v1 := Vector3( half, 0.0, -half)
	var v2 := Vector3( half, 0.0,  half)
	var v3 := Vector3(-half, 0.0,  half)
	var apex := Vector3(0.0, _height, 0.0)

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(_mat)

	var tri := func(a: Vector3, b: Vector3, c: Vector3, ua: Vector2, ub: Vector2, uc: Vector2) -> void:
		if !_smooth_shading:
			var n := Plane(a, b, c).normal
			st.set_normal(n)
		if _generate_uvs: st.set_uv(ua)
		st.add_vertex(a)
		if _generate_uvs: st.set_uv(ub)
		st.add_vertex(b)
		if _generate_uvs: st.set_uv(uc)
		st.add_vertex(c)

	tri.call(v0, v1, apex, Vector2(0,0), Vector2(1,0), Vector2(0.5,1))
	tri.call(v1, v2, apex, Vector2(0,0), Vector2(1,0), Vector2(0.5,1))
	tri.call(v2, v3, apex, Vector2(0,0), Vector2(1,0), Vector2(0.5,1))
	tri.call(v3, v0, apex, Vector2(0,0), Vector2(1,0), Vector2(0.5,1))

	tri.call(v0, v2, v1, Vector2(0,0), Vector2(1,1), Vector2(1,0))
	tri.call(v0, v3, v2, Vector2(0,0), Vector2(0,1), Vector2(1,1))

	if _smooth_shading: st.generate_normals()
	return st.commit()

func _rebuild_collision(mesh: Mesh = null) -> void:
	if _shape_node == null: return
	if mesh == null: mesh = _mesh_instance.mesh
	if mesh == null:
		_shape_node.shape = null
		return
	var shape: Shape3D = mesh.create_convex_shape() if collision_type == 0 else mesh.create_trimesh_shape()
	_shape_node.shape = shape
