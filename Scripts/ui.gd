extends Control
class_name UI

var crystals: Array[Node]
var total_crystals: int

func _get_not_collected_crystals() -> Array[Node]:
	var crystals: Array = get_tree().get_nodes_in_group("time_crystal").filter(
		func(crystal: TimeCrystal) -> bool: return !crystal.is_collected
	)
	
	return crystals

func _on_crystal_collected() -> void:
	crystals = _get_not_collected_crystals()
	var progress: float = float(total_crystals - crystals.size()) / float(total_crystals) * 1.13
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($ProgressInner, "scale", Vector2(progress, progress), 0.3)

func _on_time_change(time_frame: int) -> void:
	var clock_rot := 90.0 * time_frame
	var tween := get_tree().create_tween()
	var ball_colour := Color.WHITE
	
	match time_frame:
		0:
			ball_colour = Color.CYAN
		1:
			ball_colour = Color.DARK_SLATE_BLUE
		2:
			ball_colour = Color.BROWN
	
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property($player_indicator/clock_pivot as Control, "rotation_degrees", clock_rot, 2.0)
	tween.parallel().tween_property($player_indicator/player_ball_rect, "scale", Vector2.ONE + Vector2.ONE * time_frame, 2.0)
	tween.parallel().tween_property($player_indicator/player_ball_rect, "modulate", ball_colour, 2.0)

func _ready() -> void:
	crystals = _get_not_collected_crystals()
	total_crystals = crystals.size()
	for crystal: TimeCrystal in crystals:
		crystal.collected.connect(_on_crystal_collected)
	$ProgressInner.scale = Vector2(0, 0)
