extends CanvasLayer

signal Unpause()

@onready var Music:AudioStreamPlayer = get_node("PauseMusic")

func Setup(Icon:String):
	%Icon.texture = load("res://Songs/"+Utils.NextSongToPlay+"/"+Icon)

func Pause():
	$Buttons.position.x = 35
	$Background.color.a = 0.3
	%IconContainer.position.x = 961
	$Counter.visible = false
	self.visible = true
	
	Music.pitch_scale = 0.1
	Music.volume_db = -60

	Music.play()

	var bgmusictweener = create_tween().set_parallel(true)
	bgmusictweener.tween_property(Music, "pitch_scale", 1.0, 1.2)
	bgmusictweener.tween_property(Music, "volume_db", 0.0, 1.0)

	var tweener = create_tween().set_parallel(true)
	tweener.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)

	var id = -1
	for button:Button in $Buttons.get_children():
		id += 1
		button.offset_transform_position.x = -400
		tweener.tween_property(button, "offset_transform_position:x", 0, 0.8).set_delay(0.2*id)

func _process(delta: float) -> void:
	%IconContainer.rotation = sin(deg_to_rad(Time.get_ticks_msec() * 0.2)) * 0.08
	%IconShadow.rotation = %IconContainer.rotation
	%IconShadow.position = %IconContainer.position

func _on_resume_pressed():
	Music.stop()
	$Counter.StartTickdown()
	var twn = create_tween().set_parallel(true)
	twn.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	twn.tween_property($Buttons, "position:x", -430, 0.8)
	twn.tween_property($Background, "color:a", 0.0, 1.0)
	twn.tween_property(%IconContainer, "position:x", 1330.0, 0.8)


func _on_restart():
	get_tree().reload_current_scene()

func _back():
	get_tree().change_scene_to_file("uid://b8rvgonqqu8re")

func _on_pause_music_beat(beat: int):
	pass # Replace with function body.
