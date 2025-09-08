extends Node3D
class_name MazePart
var index : int = 0
var is_on := false
var game_won := false
signal hit_part(index: int)

@onready var indicator := $indicator

func _on_area_3d_body_entered(body: Node3D) -> void:
	if game_won:
		return
		
	if body is Player:
		visible = true
		$indicator.visible = true
		$AudioStreamPlayer3D.stream = load("res://Audio/SoundFX/maze_flip_on.mp3")
		$AudioStreamPlayer3D.play()
		is_on = true
		hit_part.emit(index)
		
		indicator.scale = Vector3.ZERO
		var indicator_mat :Material= indicator.get_active_material(0)
		indicator_mat.emission_energy_multiplier = 0.0
		var tween := get_tree().create_tween()
		tween.tween_property(indicator, "scale", Vector3.ONE, 0.4)
		tween.tween_property(indicator_mat, "emission_energy_multiplier", 6.0, 0.4)

func reset() -> void:
	indicator.visible = false
	is_on = false
	
func should_be_visible(level: String) -> bool:
	var is_visible := level == "past" && is_on
	indicator.visible = is_visible
	return is_visible
