extends Node3D

@onready var buttons: Array[TriangleButton] = [$Green, $Blue, $Red, $Yellow]
@onready var progress_indicators: Array[Node] = $ProgressIndicators.get_children()
@onready var timer: Timer = $Timer
@export var cage: Cage

var input_allowed: bool = true
var game_sequence: Array[TriangleButton]
var player_inputting: bool = false
var player_sequence_step: int = 0
var active: bool = false
var game_started: bool = false

func _play_game_animation() -> void:
	while not player_inputting and active:
		for button in game_sequence:
			if player_inputting:
				return
			await cage.pulse(_button_to_color(button))
			timer.start(0.3)
			await timer.timeout
		if player_inputting:
			return
		timer.start(4)
		await timer.timeout

func _add_random_button_to_sequence() -> void:
	game_sequence.append(buttons.pick_random())

func _start_game() -> void:
	timer.start(3)
	await timer.timeout
	_add_random_button_to_sequence()
	print(game_sequence)
	_play_game_animation()

func _button_to_color(button: TriangleButton) -> Color:
	match button.name:
		"Green": return Color.GREEN
		"Blue": return Color.BLUE
		"Red": return Color.RED
		"Yellow": return Color.YELLOW
	
	printerr("unknown color: ", name)
	return Color.WHITE

func _win() -> void:
	var tween := create_tween()
	tween.set_parallel()
	for indicator in progress_indicators:
		var material: StandardMaterial3D = indicator.get_child(0).get_material_override()
		tween.tween_property(material, "emission", Color.PURPLE, 0.5)
	var material := cage.get_material()
	tween.tween_property(material, "emission", Color.PURPLE, 0.5)
	tween.tween_property(material, "emission_energy_multiplier", 3, 0.5)
	cage.open()

func _begin_button_press() -> void:
	player_inputting = true
	timer.stop()
	timer.timeout.emit()
	input_allowed = false

func _press_is_correct(button: TriangleButton) -> bool:
	return player_sequence_step < game_sequence.size() \
	 and button == game_sequence[player_sequence_step]

func _on_button_pressed(button: TriangleButton) -> void:
	if not input_allowed:
		return

	_begin_button_press()

	if _press_is_correct(button):
		_set_indicator_on(progress_indicators[player_sequence_step], true)
		player_sequence_step += 1
		await cage.pulse(_button_to_color(button))
		if player_sequence_step == game_sequence.size() and game_sequence[-1] == button:
			if game_sequence.size() == progress_indicators.size():
				_win()
				return
			player_sequence_step = 0
			player_inputting = false
			_start_game()
	else:
		game_sequence = []
		player_sequence_step = 0
		await cage.pulse(_button_to_color(button))
		await _reset_indicators()
		player_inputting = false
		_start_game()
	
	input_allowed = true

func _reset_indicators() -> void:
	var master := create_tween().parallel()
	var stagger := 0.02

	for i in progress_indicators.size():
		var subt := _set_indicator_on(progress_indicators[(progress_indicators.size() - 1) - i], false)
		master.tween_subtween(subt).set_delay(i * stagger)

	await master.finished

func _set_indicator_on(indicator: StaticBody3D, on: bool) -> Tween:
	var material: StandardMaterial3D = indicator.get_child(0).get_material_override()
	var tween := create_tween()
	tween.tween_property(material, "emission_energy_multiplier", 3 if on else 0, 0.5)
	return tween

func _ready() -> void:
	for button: TriangleButton in buttons:
		button.pressed.connect(_on_button_pressed)
	for indicator in progress_indicators:
		var mesh: MeshInstance3D = indicator.get_child(0)
		var material: StandardMaterial3D = mesh.get_active_material(0)
		mesh.material_override = material.duplicate()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player and not active:
		active = true
		_start_game()
