extends AudioStreamPlayer

signal Beat(beat:int)
signal Step(step:int)

@export_range(0,999, 0.01, "hide_control") var BPM:float = 120.0

var curBeat := -1.0
var curStep := -1.0
var songPosition := -1.0

var songPositionBeats := -1.0

var lastBeat := -1
var lastStep := -1

@warning_ignore("unused_parameter")
func _physics_process(dt:float) -> void:
	songPosition = get_playback_position() * 1000
	var msperbeat = (60.0 / BPM) * 1000.0
	songPositionBeats = songPosition / msperbeat
	curBeat = songPositionBeats
	curStep = curBeat * 4
	
	if roundi(curBeat) > lastBeat:
		lastBeat = roundi(curBeat)
		emit_signal("Beat", roundi(curBeat))
	
	if roundi(curStep) > lastStep:
		lastStep = roundi(curStep)
		emit_signal("Step", roundi(curStep))
