extends Node3D

@onready var buttons: Array[TriangleButton] = [$Green, $Blue, $Red, $Yellow]
@export var cage: Cage

var game_sequence: Array[TriangleButton]
var player_inputting: bool = false
var player_sequence_step: int = 0

func _play_game_animation() -> void:
	while not player_inputting:
		for button in game_sequence:
			if player_inputting:
				return
			await cage.pulse(_button_to_color(button))
			await get_tree().create_timer(1).timeout
		await get_tree().create_timer(4).timeout

func _add_random_button_to_sequence() -> void:
	game_sequence.append(buttons.pick_random())

func _start_game() -> void:
	_add_random_button_to_sequence()
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
	player_inputting = true
	cage.pulse(_button_to_color(button))
	if player_sequence_step < game_sequence.size() and button == game_sequence[player_sequence_step]:
		print("correct!")
		if game_sequence[-1] == button:
			print("final step!")
			player_inputting == false
			_add_random_button_to_sequence()
			print(game_sequence)
			_play_game_animation()
	else:
		print("incorrect")
		game_sequence = []
		player_sequence_step = 0
		for i in range(3):
			await cage.pulse(_button_to_color(button))
			await get_tree().create_timer(0.2).timeout
		_add_random_button_to_sequence()
		_play_game_animation()

func _ready() -> void:
	for button: TriangleButton in buttons:
		button.pressed.connect(_on_button_pressed)
	_start_game()
