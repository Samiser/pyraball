extends Control

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
	print(progress)
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($ProgressInner, "scale", Vector2(progress, progress), 0.3)

func _ready() -> void:
	crystals = _get_not_collected_crystals()
	total_crystals = crystals.size()
	for crystal: TimeCrystal in crystals:
		crystal.collected.connect(_on_crystal_collected)
	print(total_crystals)
	$ProgressInner.scale = Vector2(0, 0)
