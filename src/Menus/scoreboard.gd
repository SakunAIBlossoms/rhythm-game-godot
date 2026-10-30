extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var file = FileAccess.open("res://Songs/"+Utils.NextSongToPlay+"/meta.txt", FileAccess.READ)
	var raw = file.get_as_text()
	var data = raw.split(":")
	var dict = {
		"Name" = data[0],
		"Cover" = load("res://Songs/"+Utils.NextSongToPlay+"/"+data[1]),
		"BPM" = float(data[2]),
		"PreviewTime" = float(data[3]),
		"AudioFile" = data[4],
		"Artist" = data[5],
		"Mapper" = data[6],
		"ExtraPlayfields" = data[7]
	}
	
	%IconContainer.position.x = -356.
	%SongName.position.y = -230.
	%Credit.position.y = -127.
	
	%Icon.texture = dict["Cover"]
	%SongName.text = "[wave]"+dict["Name"]
	%Credit.text = "[wave]"+dict["Artist"]+" - "+dict["Mapper"]
	
	Utils.DoTweenProperty(%IconContainer, "position:x", 36.0, 0.8,Tween.EASE_IN_OUT, Tween.TRANS_EXPO)
	Utils.DoTweenProperty(%SongName, "position:y", 55.0, 0.8,Tween.EASE_IN_OUT, Tween.TRANS_EXPO)
	Utils.DoTweenProperty(%Credit, "position:y", 158.0, 0.8,Tween.EASE_IN_OUT, Tween.TRANS_EXPO)
	
	if Utils.PlayerCurrentScore != null:
		var id = -1
		for node in $Scores/List.get_children():
			id += 1
			create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC).tween_property(node, "modulate:a", 1.0, 0.4).from(0.0).set_delay(0.2*id)
	else:
		$Scores/Fail.visible = true
		$Scores/List.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == Key.KEY_ENTER and event.is_released():
			get_tree().change_scene_to_file("res://src/Menus/SongSelect.tscn")

var perfects = 0.0
var goods = 0.0
var bads = 0.0
var misses = 0.0
var noteshit = 0.0

func _process(delta: float) -> void:
	if Utils.PlayerCurrentScore != null:
		perfects = lerp(perfects, float(Utils.PlayerCurrentScore.Perfects), 12*delta)
		goods = lerp(goods, float(Utils.PlayerCurrentScore.Goods), 12*delta)
		bads = lerp(bads, float(Utils.PlayerCurrentScore.Bads), 12*delta)
		misses = lerp(misses, float(Utils.PlayerCurrentScore.Misses), 12*delta)
		noteshit = lerp(noteshit, float(Utils.PlayerCurrentScore.NotesHit), 12*delta)
		%Perfects.text = "Perfects: "+str(int(perfects))
		%Goods.text = "Goods: "+str(int(goods))
		%Bads.text = "Bads: "+str(int(bads))
		%Misses.text = "Misses: "+str(int(misses))
		%"Notes Hit".text = "Notes Hit: "+str(int(noteshit))
	
	%IconContainer.rotation = sin(deg_to_rad(Time.get_ticks_msec() * 0.2)) * 0.08
	%IconShadow.rotation = %IconContainer.rotation
	%IconShadow.position = %IconContainer.position
