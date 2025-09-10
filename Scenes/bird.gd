extends Node3D

var time := 0.04
var amplitude := 24.0
var flap_speed := 4.0
var fly_speed := 3.0

@export var path : PathFollow3D

func _process(delta: float) -> void:
	time += delta
	$wing_l.rotation_degrees.z = 90.0 + sin(time * flap_speed) * amplitude
	$wing_r.rotation_degrees.z = 90.0 + sin(time* flap_speed) * -amplitude
	path.progress += delta * fly_speed
