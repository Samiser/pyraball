extends Node3D

@onready var items_parent := $items_parent
var has_player_entered := false

func _ready() -> void:
	for child in items_parent.get_children():
		child.visible = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if !body.is_in_group("player"):
		return
	
	if !has_player_entered:
		_reveal_items()
	
	has_player_entered = true

func _reveal_items() -> void:
	for child in items_parent.get_children():
		await get_tree().create_timer(0.2).timeout
		if child:
			child.visible = true
