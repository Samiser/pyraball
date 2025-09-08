extends Node3D
var correct_parts : Array = [24, 20, 15, 10, 11, 12, 13, 8, 3, 2, 1, 0]
var parts_hit : Array
var won := false

func _ready() -> void:
	var index := 0
	for child: MazePart in $parts.get_children():
		child.index = index
		child.hit_part.connect(child_hit)
		index += 1

func child_hit(index: int) -> void:
	if won:
		return
	
	if !correct_parts.has(index):
		_reset()
		return
	
	if parts_hit.has(index):
		return
	
	parts_hit.insert(0, index)
	if parts_hit.size() == 12:
		_win()

func _win() -> void:
	won = true
	$AudioStreamPlayer3D.stream = load("res://Audio/SoundFX/maze_win.mp3")
	$AudioStreamPlayer3D.play()
	for child: MazePart in $parts.get_children():
		child.game_won = true
	
func _reset() -> void:
	for child: MazePart in $parts.get_children():
		child.reset()
	parts_hit.clear()
	$AudioStreamPlayer3D.stream = load("res://Audio/SoundFX/maze_flip_off.mp3")
	$AudioStreamPlayer3D.play()
