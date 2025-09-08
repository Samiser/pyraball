extends Node3D

@onready var buttons: Array[TriangleButton] = [$Green, $Blue, $Red, $Yellow]
@onready var timer: Timer = $Timer
@export var cage: Cage

var input_allowed: bool = true
var game_sequence: Array[TriangleButton]
var player_inputting: bool = false
var player_sequence_step: int = 0
var active: bool = false
var game_started: bool = false

func _play_game_animation() -> void:
	print("starting animation ", game_sequence)
	while not player_inputting and active:
		for button in game_sequence:
			print("starting loop")
			if player_inputting:
				print("player inputting during loop, stopping animation")
				return
			print("pulsing ", _button_to_color(button), " from sequence ", game_sequence)
			await cage.pulse(_button_to_color(button))
			timer.start(0.3)
			await timer.timeout
		if player_inputting:
			print("player inputting during loop, stopping animation")
			return
		timer.start(4)
		await timer.timeout
	print("player inputting, stopping animation")

func _add_random_button_to_sequence() -> void:
	game_sequence.append(buttons.pick_random())

func _start_game() -> void:
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

func _on_button_pressed(button: TriangleButton) -> void:
	if not input_allowed:
		return
	player_inputting = true
	timer.stop()
	timer.timeout.emit()
	input_allowed = false
	print(button)
	if button in game_sequence:
		print(button)
	await cage.pulse(_button_to_color(button))
	if player_sequence_step < game_sequence.size() and button == game_sequence[player_sequence_step]:
		print("correct!")
		player_sequence_step += 1
		if player_sequence_step == game_sequence.size() and game_sequence[-1] == button:
			print("final step!")
			player_inputting = false
			player_sequence_step = 0
			_start_game()
	else:
		print("incorrect")
		game_sequence = []
		player_sequence_step = 0
		player_inputting = false
		_start_game()
	player_inputting = false
	input_allowed = true

func _ready() -> void:
	for button: TriangleButton in buttons:
		button.pressed.connect(_on_button_pressed)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player and not active:
		active = true
		_start_game()
