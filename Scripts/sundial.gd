extends Node3D
class_name Sundial

@export var button: TriangleButton
@export var reflectors: Array[Reflector]

@onready var markers := [$Three, $Six, $Nine, $Twelve]
var highlighted_markers: Array[Node3D] = []

var original_marker_color: Color = Color.WHITE
var speed: float = -0.3
var backwards: bool = false

signal completed

func change_speed(amount: float) -> void:
	speed += amount

func _process(delta: float) -> void:
	$LightPivot.rotate_y(speed * delta)

func get_target_position() -> Vector3:
	return $TargetSphere.global_position

func _tween_color(marker: Pyramid, new_color: Color) -> void:
	var tween := create_tween()
	tween.tween_property(marker, "color", new_color, 0.5)

func _on_shadow_area_entered(area: Area3D) -> void:
	var marker: Node3D = area.get_parent()
	if marker.is_in_group("clock_marker") and not marker in highlighted_markers:
		original_marker_color = marker.color
		_tween_color(marker, Color.CYAN)

func _on_shadow_area_exited(area: Area3D) -> void:
	var marker: Node3D = area.get_parent()
	if marker.is_in_group("clock_marker") and not marker in highlighted_markers:
		_tween_color(marker, original_marker_color)

func _animate_reversal() -> void:
	$AudioStreamPlayer3D.play()
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "speed", 20, 5)
	tween.tween_property(self, "speed", 0.3, 3)
	await tween.finished

func _all_reflectors_oriented() -> bool:
	var all_oriented: bool = true
	
	for reflector in reflectors:
		if not reflector.facing_sundial:
			all_oriented = false
	
	return all_oriented 

func _on_button_pressed(_button: TriangleButton) -> void:
	if backwards:
		return
	
	if not _all_reflectors_oriented():
		change_speed(0.2)
	else:
		backwards = true
		await _animate_reversal()
		completed.emit()

func _on_button_released(_button: TriangleButton) -> void:
	if backwards:
		return
	
	if not _all_reflectors_oriented():
		change_speed(-0.2)

func _reflector_completed() -> void:
	var count := 0

	for reflector in reflectors:
		if reflector.facing_sundial:
			count += 1
	
	var marker: Node3D = markers[count - 1]
	highlighted_markers.append(marker)
	_tween_color(marker, Color.CYAN)

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	button.released.connect(_on_button_released)
	
	for reflector in reflectors:
		reflector.completed.connect(_reflector_completed)
