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

var first_control: Control

var time := 0.0
var cog_speed := 0.2

signal sensitivity_changed(type: String, value: float)
signal invert_changed(type: String, value: bool)
signal graphics_changed(value: bool)

var previous_menu: Control

func _set_volume(bus: int, value: float) -> void:
	AudioServer.set_bus_volume_linear(bus, value)

func set_sensitivity(type: String, value: float) -> void:
	match type:
		"mouse":
			mouse_sensitivity_slider.value = value
		"gamepad":
			gamepad_sensitivity_slider.value = value

func set_visible_from(menu: Control) -> void:
	previous_menu = menu
	visible = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	first_control = master_volume_slider
	
	master_volume_slider.value = AudioServer.get_bus_volume_linear(master_bus)
	music_volume_slider.value = AudioServer.get_bus_volume_linear(music_bus)
	
	master_volume_slider.value_changed.connect(_master_vol_changed)
	_master_vol_changed(master_volume_slider.value)
	music_volume_slider.value_changed.connect(_music_vol_changed)
	_music_vol_changed(music_volume_slider.value)

	mouse_sensitivity_slider.value_changed.connect(_m_sens_changed)
	_m_sens_changed(mouse_sensitivity_slider.value)
	gamepad_sensitivity_slider.value_changed.connect(_gpad_sens_changed)
	_gpad_sens_changed(gamepad_sensitivity_slider.value)
	
	invert_x_toggle.toggled.connect(func(value: bool) -> void: invert_changed.emit("x", value))
	invert_y_toggle.toggled.connect(func(value: bool) -> void: invert_changed.emit("y", value))
	
	graphics_toggle.toggled.connect(func(value: bool) -> void: graphics_changed.emit(value))

	close_button.pressed.connect(func() -> void: visible = false; previous_menu.visible = true)
	
	visibility_changed.connect(func() -> void: if visible: master_volume_slider.grab_focus())

func _master_vol_changed(value: float) -> void:
	_set_volume(master_bus, value)
	var percent :int= (value / master_volume_slider.max_value) * 100
	$MarginContainer/VBoxContainer/HBoxContainer/master_vol_label.text = "master volume:\n" + str(percent) + "%"

func _music_vol_changed(value: float) -> void:
	_set_volume(music_bus, value)
	var percent :int= (value / music_volume_slider.max_value) * 100
	$MarginContainer/VBoxContainer/HBoxContainer2/music_vol_slider.text = "music volume:\n" + str(percent) + "%"

func _m_sens_changed(value: float) -> void:
	sensitivity_changed.emit("mouse", value)
	var percent :int= (value / mouse_sensitivity_slider.max_value) * 100
	$MarginContainer/VBoxContainer/HBoxContainer3/mouse_sens_label.text = "mouse sensitivity:\n" + str(percent) + "%"

func _gpad_sens_changed(value: float) -> void:
	sensitivity_changed.emit("gamepad", value)
	var percent :int= (value / gamepad_sensitivity_slider.max_value) * 100
	$MarginContainer/VBoxContainer/HBoxContainer4/gpad_sens_label.text = "gamepad sensitivity:\n" + str(percent) + "%"

func _process(delta: float) -> void:
	time += delta
	$cog_0.rotation += delta * cog_speed
	$cog_1.rotation -= delta * cog_speed
