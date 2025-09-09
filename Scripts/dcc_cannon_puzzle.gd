extends Node3D

@onready var moving_cannon :Node3D= $Cannon2#
var time := 0.0
var starting_y := 0.0
func _ready() -> void:
	starting_y = moving_cannon.global_position.y
func _process(delta: float) -> void:
	time += delta
	moving_cannon.global_position.y = starting_y + sin(time) * 3.0
