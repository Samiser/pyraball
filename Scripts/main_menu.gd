extends Control

@export var play_button: Button
@export var options_button: Button
@export var exit_button: Button

var time := 0.0

signal play
signal options

var first_control: Control

func _ready() -> void:
	first_control = play_button
	play_button.pressed.connect(func() -> void: play.emit())
	exit_button.pressed.connect(func() -> void: get_tree().quit())
	options_button.pressed.connect(func() -> void: visible = false; options.emit())
	play_button.grab_focus()
	visibility_changed.connect(func() -> void: if visible: play_button.grab_focus())

func _process(delta: float) -> void:
	time += delta
	$VBoxContainer/CenterContainer/logo_text/logo_bg.rotation += delta * 0.1
	$VBoxContainer/CenterContainer/logo_text.self_modulate = Color.WHITE * (0.8 + sin(time * 2.0) * 0.2)
	
