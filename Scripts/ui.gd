extends Control
class_name UI

var crystals: Array[Node]
var total_crystals: int
var fade_in_time := 0.8

var completion_seconds: int = 0

func set_instruction_text(text: String) -> void:
	$instruction_text.visible_ratio = 0.0
	$instruction_text.text = text
	$instruction_text.modulate = Color.WHITE
	
	var tween := get_tree().create_tween()
	tween.tween_property($instruction_text as RichTextLabel, "visible_ratio", 1.0, 3.0)
	
	await tween.finished
	await get_tree().create_timer(12.0).timeout
	
	tween = get_tree().create_tween()
	tween.tween_property($instruction_text as RichTextLabel, "modulate", Color.TRANSPARENT, 6.0)

func get_completion_time() -> String:
	var seconds := completion_seconds%60
	var minutes := (completion_seconds/60)%60
	var hours := (completion_seconds/60)/60
	
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

func _get_not_collected_crystals() -> Array[Node]:
	var crystals: Array = get_tree().get_nodes_in_group("time_crystal").filter(
		func(crystal: TimeCrystal) -> bool: return !crystal.is_collected
	)
	
	return crystals

func fade_in() -> void:
	var tween := create_tween()
	for element: Control in [$SubViewportContainer, $ProgressBar, $player_indicator]:
		tween.parallel().tween_property(element, "modulate:a", 1, fade_in_time)

func fade_out() -> void: # hacky shit for ending only
	$CompletionTimer.stop()
	$end_text.text = "thanks for playing! you restored the world in  [color=\"5d38ff\"]%s[/color]" % get_completion_time()
	var tween := create_tween()
	for element: Control in [$SubViewportContainer, $ProgressBar, $player_indicator]:
		tween.parallel().tween_property(element, "modulate:a", 0, fade_in_time * 2.0)
	await tween.finished
	await get_tree().create_timer(16.0).timeout
	tween = create_tween()
	tween.tween_property($end_label, "modulate", Color.WHITE, 4.0)
	tween.tween_interval(1.0)
	tween.tween_property($end_text, "modulate", Color.WHITE, 4.0)
	await tween.finished
	await get_tree().create_timer(4.0).timeout
	tween = create_tween()
	tween.tween_property($end_label, "modulate", Color.TRANSPARENT, 8.0)
	tween.parallel().tween_property($end_text, "modulate", Color.TRANSPARENT, 8.0)
	await tween.finished
	#restart game here?

func _on_crystal_collected() -> void:
	crystals = _get_not_collected_crystals()
	var progress: float = float(total_crystals - crystals.size()) / float(total_crystals) * 1.13
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($ProgressBar/ProgressInner, "scale", Vector2(progress, progress), 0.3)

func _on_time_change(time_frame: int) -> void:
	await get_tree().create_timer(0.5).timeout # make it animate more after game freeze...
	
	var clock_rot := 90.0 * time_frame
	var tween := get_tree().create_tween()
	var ball_colour := Color.WHITE
	
	if time_frame == 0:
		$player_indicator.visible = true
	
	match time_frame:
		0:
			ball_colour = Color.CYAN
		1:
			ball_colour = Color.DARK_SLATE_BLUE
		2:
			ball_colour = Color.BROWN
	
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property($player_indicator/clock_pivot as Control, "rotation_degrees", clock_rot, 2.0)
	tween.parallel().tween_property($player_indicator/player_ball_rect, "scale", Vector2.ONE + Vector2.ONE * time_frame, 2.0)
	tween.parallel().tween_property($player_indicator/player_ball_rect, "modulate", ball_colour, 2.0)

func _ready() -> void:
	$CompletionTimer.timeout.connect(func() -> void: completion_seconds += 1)
	for element: Control in [$SubViewportContainer, $ProgressBar, $player_indicator, $end_label, $end_text]:
		element.modulate.a = 0
	crystals = _get_not_collected_crystals()
	total_crystals = crystals.size()
	for crystal: TimeCrystal in crystals:
		crystal.collected.connect(_on_crystal_collected)
	$ProgressBar/ProgressInner.scale = Vector2(0, 0)
