extends Control

@export var play_button: Button
@export var options_button: Button
@export var exit_button: Button

var time := 0.0

signal play
signal options

func _ready() -> void:
	play_button.pressed.connect(func() -> void: play.emit())
	exit_button.pressed.connect(func() -> void: get_tree().quit())
	options_button.pressed.connect(func() -> void: visible = false; options.emit())

func _process(delta: float) -> void:
	time += delta
	$VBoxContainer/CenterContainer/logo_text/logo_bg.rotation += delta * 0.1
	$VBoxContainer/CenterContainer/logo_text.self_modulate = Color.WHITE * (0.8 + sin(time * 2.0) * 0.2)
