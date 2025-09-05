extends Control

var crystals: Array[Node]
var total_crystals: int

func _on_crystal_collected() -> void:
	crystals = get_tree().get_nodes_in_group("time_crystal").filter(
		func(crystal: TimeCrystal) -> bool: return !crystal.is_collected
	)
	print(crystals.size())
	var progress: float = float(total_crystals - crystals.size()) / float(total_crystals)
	print(total_crystals, " ", crystals.size(), " ", total_crystals - crystals.size())
	print(progress)
	$ProgressInner.scale = Vector2(progress, progress)

func _ready() -> void:
	crystals = get_tree().get_nodes_in_group("time_crystal")
	total_crystals = crystals.size()
	for crystal: TimeCrystal in crystals:
		crystal.collected.connect(_on_crystal_collected)
	print(total_crystals)
	$ProgressInner.scale = Vector2(0, 0)
