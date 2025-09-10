extends Control

@export var resume_button: Button
@export var options_button: Button
@export var exit_button: Button

@export var options_menu: OptionsMenu

var playing: bool = false

signal options

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and playing:
		if options_menu.visible:
			options_menu.previous_menu.visible = true
			options_menu.visible = false
		elif visible == true:
			_resume()
		else:
			get_tree().paused = true
			visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _resume() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	visible = false
	get_tree().paused = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_resume)
	exit_button.pressed.connect(func() -> void: get_tree().quit())
	options_button.pressed.connect(func() -> void: visible = false; options_menu.set_visible_from(self))
	resume_button
