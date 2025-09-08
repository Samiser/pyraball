extends Node3D

@onready var buttons: Array[TriangleButton] = [$Green, $Blue, $Red, $Yellow]

func _on_button_pressed(button: TriangleButton) -> void:
	print(button)

func _ready() -> void:
	for button: TriangleButton in buttons:
		button.pressed.connect(_on_button_pressed)
