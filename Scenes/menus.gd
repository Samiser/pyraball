extends Control

@onready var main_menu := $MainMenu
@onready var options_menu := $OptionsMenu
@onready var pause_menu := $PauseMenu

var using_gamepad: bool = false

func _any_menus_visible() -> bool:
	for menu in get_children():
		if menu.visible:
			return true
	return false

func _input(event: InputEvent) -> void:
	print(event)
	if _any_menus_visible() and event is InputEventMouseMotion and using_gamepad:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		for control: Control in get_tree().get_nodes_in_group("ui_control"):
			control.focus_mode = Control.FOCUS_NONE
			control.mouse_filter = Control.MOUSE_FILTER_STOP
			control.release_focus()
		using_gamepad = false
	elif _any_menus_visible() and (event is InputEventJoypadButton or event is InputEventJoypadMotion) and not using_gamepad:
		print("now here")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		for control: Control in get_tree().get_nodes_in_group("ui_control"):
			control.focus_mode = Control.FOCUS_ALL
			control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for menu: Control in get_children():
			if menu.visible:
				menu.first_control.grab_focus()
		using_gamepad = true

func start() -> void:
	pause_menu.playing = true
	main_menu.visible = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	main_menu.options.connect(func() -> void: options_menu.set_visible_from(main_menu))
