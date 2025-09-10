extends Control
class_name OptionsMenu

@export var master_volume_slider: HSlider
@export var music_volume_slider: HSlider
@export var mouse_sensitivity_slider: HSlider
@export var gamepad_sensitivity_slider: HSlider
@export var invert_x_toggle: CheckButton
@export var invert_y_toggle: CheckButton
@export var graphics_toggle: CheckButton
@export var close_button: Button

@onready var master_bus := AudioServer.get_bus_index("Master")
@onready var music_bus := AudioServer.get_bus_index("Music")

signal sensitivity_changed(type: String, value: float)
signal invert_changed(type: String, value: bool)
signal graphics_changed(value: bool)
signal closed

func _set_volume(bus: int, value: float) -> void:
	AudioServer.set_bus_volume_linear(bus, value)

func set_sensitivity(type: String, value: float) -> void:
	match type:
		"mouse":
			mouse_sensitivity_slider.value = value
		"gamepad":
			gamepad_sensitivity_slider.value = value

func _ready() -> void:
	master_volume_slider.value = AudioServer.get_bus_volume_linear(master_bus)
	music_volume_slider.value = AudioServer.get_bus_volume_linear(music_bus)
	
	master_volume_slider.value_changed.connect(func(value: float) -> void: _set_volume(master_bus, value))
	music_volume_slider.value_changed.connect(func(value: float) -> void: _set_volume(music_bus, value))

	mouse_sensitivity_slider.value_changed.connect(func(value: float) -> void: sensitivity_changed.emit("mouse", value))
	gamepad_sensitivity_slider.value_changed.connect(func(value: float) -> void: sensitivity_changed.emit("gamepad", value))
	
	invert_x_toggle.toggled.connect(func(value: bool) -> void: invert_changed.emit("x", value))
	invert_y_toggle.toggled.connect(func(value: bool) -> void: invert_changed.emit("y", value))
	
	graphics_toggle.toggled.connect(func(value: bool) -> void: graphics_changed.emit(value))

	close_button.pressed.connect(func() -> void: visible = false; closed.emit())
