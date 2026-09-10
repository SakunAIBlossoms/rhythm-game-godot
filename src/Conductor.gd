extends AudioStreamPlayer

@export_range(0,999, 0.01, "hide_control") var BPM:float = 120.0

var curBeat := -1.0

func LoadSong(data:Dictionary):
	
	pass

func _physics_process(dt:float) -> void:
	curBeat = get_playback_position() * BPM / 60
	pass
