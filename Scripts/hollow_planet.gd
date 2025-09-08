extends Node3D

var has_player_entered := false
@onready var sphere := $CSGSphere3D

func _process(delta: float) -> void:
	sphere.rotate_y(0.1 * delta)

# removed old functionality - might not need this script anymore
func _on_area_3d_body_entered(body: Node3D) -> void:
	if !body is Player:
		return
		
	has_player_entered = true

func should_be_visible(level: String) -> bool:
	var is_visible := get_groups().has(level)
	sphere.use_collision = is_visible
	return is_visible
