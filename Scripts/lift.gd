extends AnimatableBody3D
class_name Lift

@export var lower_position := Vector3.ZERO
@export var lower_rotation := Vector3.ZERO
@export var upper_position := Vector3.ZERO
@export var upper_rotation := Vector3.ZERO
@export var lower_button: TriangleButton
@export var upper_button: TriangleButton
@export_enum("lower", "upper") var starting_position: int

@onready var my_level: Level = _find_level()
@onready var button: TriangleButton = $Button

var moving: bool = false
var current_position: int = 0

func _find_level() -> Level:
	var n := self as Node
	while n and not (n is Level):
		n = n.get_parent()
	return n

func _snap_to(new_position: Vector3, new_rotation: Vector3) -> void:
	position = new_position
	rotation = new_rotation

func _move_to(new_position: Vector3, new_rotation: Vector3) -> void:
	var present_lift: Lift
	var future_lift: Lift
	
	if my_level.selected_level == 0:
		present_lift = my_level.get_counterpart(self, my_level.present)
		future_lift = my_level.get_counterpart(self, my_level.future)
	elif my_level.selected_level == 1:
		future_lift = my_level.get_counterpart(self, my_level.future)
	
	if present_lift:
		present_lift._snap_to(new_position, new_rotation)
	
	if future_lift:
		present_lift._snap_to(new_position, new_rotation)
	
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

func _on_lower_pressed(_b: TriangleButton) -> void:
	if current_position:
		_move_to(lower_position, lower_rotation)

func _on_upper_pressed(_b: TriangleButton) -> void:
	if !current_position:
		_move_to(upper_position, upper_rotation)

func _ready() -> void:
	lower_button.pressed.connect(_on_lower_pressed)
	upper_button.pressed.connect(_on_upper_pressed)
	button.pressed.connect(_lift_button_pressed)
	current_position = starting_position
	print(my_level)
