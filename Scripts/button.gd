extends Node3D
class_name TriangleButton

@export var color: Color = Color.RED

@onready var press_area: Area3D = $PressArea
@onready var actuator: RigidBody3D = $Actuator
@onready var actuator_mesh: MeshInstance3D = $"Actuator/Cone-col-rigid"

signal pressed(button: TriangleButton)
signal released(button: TriangleButton)

func _tween_actuator_color(to_color: Color, duration: float = 0.2) -> void:
	var material := actuator_mesh.get_surface_override_material(0)
	var tween := create_tween()
	tween.tween_property(material, "albedo_color", to_color, duration)

func _on_press_area_entered(body: Node3D) -> void:
	if body == actuator:
		_tween_actuator_color(color)
		emit_signal("pressed", self)

func _on_press_area_exited(body: Node3D) -> void:
	if body == actuator:
		_tween_actuator_color(color.lightened(0.5))
		emit_signal("released", self)

func set_freeze(value: bool) -> void:
	actuator.position = Vector3(0., 0.373, 0.)
	actuator.freeze = value

func _ready() -> void:
	press_area.body_entered.connect(_on_press_area_entered)
	press_area.body_exited.connect(_on_press_area_exited)
	actuator_mesh.set_surface_override_material(
		0,
		actuator_mesh.get_active_material(0).duplicate()
	)
	var material := actuator_mesh.get_surface_override_material(0)
	material.albedo_color = color.lightened(0.5)
