extends Control

@export var play_button: Button
@export var options_button: Button
@export var exit_button: Button

signal play

func _ready() -> void:
	play_button.pressed.connect(func() -> void: play.emit())
	exit_button.pressed.connect(func() -> void: get_tree().quit())
