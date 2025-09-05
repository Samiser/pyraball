extends AnimatableBody3D

@export var lower_position := Vector3.ZERO
@export var lower_rotation := Vector3.ZERO
@export var upper_position := Vector3.ZERO
@export var upper_rotation := Vector3.ZERO
@export var lower_button: TriangleButton
@export var upper_button: TriangleButton
@export_enum("lower", "upper") var starting_position: int

@onready var button: TriangleButton = $Button

var moving: bool = false
var current_position: int = 0

func _move_to(new_position: Vector3, new_rotation: Vector3) -> void:
	var tween := create_tween()
	moving = true
	tween.tween_property(self, "position", new_position, 5.)
	tween.parallel().tween_property(self, "rotation", new_rotation, 5.)
	await tween.finished
	moving = false
	current_position = !current_position

func _lift_button_pressed(_button: TriangleButton) -> void:
	if moving:
		return

	if current_position == 0:
		_move_to(upper_position, upper_rotation)
	elif current_position == 1:
		_move_to(lower_position, lower_rotation)

func _ready() -> void:
	lower_button.pressed.connect(func(_button: TriangleButton) -> void: if current_position: _move_to(lower_position, lower_rotation))
	upper_button.pressed.connect(func(_button: TriangleButton) -> void: if !current_position: _move_to(upper_position, upper_rotation))
	button.pressed.connect(_lift_button_pressed)
	current_position = starting_position
