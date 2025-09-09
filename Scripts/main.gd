extends Node3D

func _switch_music() -> void:
	var tween := create_tween()
	tween.tween_property($Music, "volume_db", -80, 2)
	tween.parallel().tween_property($Music2, "volume_db", -8, 0.1)

#func _rotate_world() -> void:
	#print("here")
	#$Player.freeze = true
	#await $World._tween_rotation(Vector3(-deg_to_rad(63.5), deg_to_rad(180), 0))
	#await $World._tween_rotation(Vector3(0, deg_to_rad(90), deg_to_rad(63.5)))
	#$Player.freeze = false

func _ready() -> void:
	$Player.rotate.connect($World._on_rotation)
	$Player.all_crystals_collected.connect($World._on_all_crystals_collected)
	$World.puzzle_completed.connect($Player.on_puzzle_completed)
	$Music2.playing = true
	$Music.playing = true
	$World.portalled.connect(_switch_music)
	for particles: Node in get_tree().get_nodes_in_group("particles"):
		particles.emitting = false
	#await _rotate_world()
