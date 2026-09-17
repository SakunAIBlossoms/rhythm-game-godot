extends AudioStreamPlayer

@export_range(0,999, 0.01, "hide_control") var BPM:float = 120.0

var curBeat := -1.0
var songPosition := -1.0

@warning_ignore("unused_parameter")
func _physics_process(dt:float) -> void:
	songPosition = get_playback_position() * 100
	curBeat = songPosition * BPM / 60
