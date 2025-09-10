extends Control

@export var resume_button: Button
@export var options_button: Button
@export var exit_button: Button

@export var options_menu: OptionsMenu

var playing: bool = false
var first_control: Control

signal options

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and playing:
		if options_menu.visible:
			options_menu.previous_menu.visible = true
			options_menu.visible = false
		elif visible == true:
			_resume()
		else:
			_pause()
			print(event)
			if event is InputEventKey:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _pause() -> void:
	get_tree().paused = true
	visible = true
	$ColorRect.modulate = Color.TRANSPARENT
	var tween := create_tween()
	tween.tween_property($ColorRect as ColorRect, "modulate", Color.WHITE, 1)
	

func _resume() -> void:
	$AudioStreamPlayer2D.play()
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	visible = false
	get_tree().paused = false

func _process(delta: float) -> void:
	$TextureRect2.rotation += delta * 0.2

func _ready() -> void:
	first_control = resume_button
	get_viewport().gui_focus_changed.connect(func(node: Control) -> void: print(node))
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_resume)
	exit_button.pressed.connect(func() -> void: get_tree().quit(); $AudioStreamPlayer2D.play())
	options_button.pressed.connect(func() -> void: visible = false; options_menu.set_visible_from(self); $AudioStreamPlayer2D.play())
	visibility_changed.connect(func() -> void: if visible: resume_button.grab_focus())
