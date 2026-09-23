extends Control

var _visfill := 0.0
var volume := 0.0
var shown = false

var amount = 5

func _process(delta: float) -> void:
	_visfill = lerp(_visfill, volume, 8*delta)
	$Bar.value = _visfill
	if shown:
		position.y = lerp(position.y, 0.0, 12*delta)
		modulate.a = lerp(modulate.a, 1.0, 12*delta)
	else:
		position.y = lerp(position.y, -60.0, 12*delta)
		modulate.a = lerp(modulate.a, 0.0, 12*delta)

func _input(event:InputEvent):
	if event is InputEventKey:
		if event.is_action_pressed("volume_up") or event.is_action_pressed("volume_down"):
			$ShowTime.stop()
			shown = true
		
		if event.is_action("volume_up") and event.is_pressed():
			volume = clampf(volume+amount, -80.0, 0.0)
			UpdateVolume()
		if event.is_action("volume_down") and event.is_pressed():
			volume = clampf(volume-amount, -80.0, 0.0)
			UpdateVolume()
		
		if event.is_action_released("volume_up") or event.is_action_released("volume_down"):
			$ShowTime.start()

func UpdateVolume():
	if volume != AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume)

func _on_show_time_timeout() -> void:
	shown = false
