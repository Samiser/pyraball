@tool
extends Node3D

const LEVEL_GROUPS: Array[String] = ["past", "present", "future"]

var levels: Array[PackedScene] = [
	preload("res://Meshes/level_past.blend"),
	preload("res://Meshes/level_present.blend"),
	preload("res://Meshes/level_future.blend"),
]

@export_enum("Past", "Present", "Future")
var selected_level: int = 0:
	set(value):
		selected_level = value
		_update_visibility()

func _update_visibility() -> void:
	for child in get_children():
		if child.is_in_group("level"):
			child.queue_free()
	
	var instance := levels[selected_level].instantiate()
	instance.add_to_group("level")
	add_child(instance)
	
	if is_inside_tree():
		_apply_group_activity()

func _apply_group_activity() -> void:
	var active_group := LEVEL_GROUPS[selected_level]
	var candidates := _collect_group_nodes(self)

	for n: Node3D in candidates.keys():
		var is_active: bool = n.is_in_group(active_group)
		_set_subtree_active_guarded(n, is_active, candidates)

func _collect_group_nodes(root: Node) -> Dictionary:
	var set := {}
	var stack: Array[Node] = [root]
	while stack.size() > 0:
		var n: Node = stack.pop_back()
		var tagged := false
		for g in LEVEL_GROUPS:
			if n.is_in_group(g):
				tagged = true
				break
		if tagged:
			set[n] = true
		for c in n.get_children():
			stack.push_back(c)
	return set

func _set_subtree_active_guarded(root: Node, active: bool, candidates: Dictionary) -> void:
	_toggle_node(root, active)
	for c in root.get_children():
		if candidates.has(c):
			continue
		_set_subtree_active_guarded(c, active, candidates)

func _toggle_node(n: Node, active: bool) -> void:
	if n is Node3D:
		(n as Node3D).visible = active

	if n is PhysicsBody3D:
		var b := n as PhysicsBody3D
		if active:
			if b.has_meta("_layer"): b.collision_layer = int(b.get_meta("_layer"))
			if b.has_meta("_mask"):  b.collision_mask  = int(b.get_meta("_mask"))
		else:
			if !b.has_meta("_layer"): b.set_meta("_layer", b.collision_layer)
			if !b.has_meta("_mask"):  b.set_meta("_mask",  b.collision_mask)
			b.collision_layer = 0
			b.collision_mask  = 0

func _ready() -> void:
	_update_visibility()
