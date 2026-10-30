extends Control

var SongObject = preload("res://src/Menus/Song.tscn")
var WaveTextBBCode = "[wave amp=60.0 freq=2.0 connected=0]"

var SongList = []
var SongObjects = []

var inputEnabled = false

var curSel = -1

func _ready() -> void:
	if Config.GetOption("GraphicsShadersEnabled") == false: $Background/Shader.queue_free()

	Overlay.get_node("Fade").color = Color.TRANSPARENT
	var list = DirAccess.get_directories_at("res://Songs/")
	var i = -1
	for song in list:
		i += 1
		%CurrentlyLoading.text = "Currently loading "+song
		var file = FileAccess.open("res://Songs/"+song+"/meta.txt", FileAccess.READ)
		var raw = file.get_as_text()
		var data = raw.split(":")
		var dict = {
			"RawName" = song,
			"Name" = data[0],
			"Cover" = load("res://Songs/"+song+"/"+data[1]),
			"BPM" = float(data[2]),
			"PreviewTime" = float(data[3]),
			"AudioFile" = data[4],
			"Artist" = data[5],
			"Mapper" = data[6],
			"ExtraPlayfields" = data[7]
		}
		SongList.push_front(dict)
		
		var s = SongObject.instantiate()
		s.Setup(dict)
		s.ID = i
		$SongList.add_child(s)
		SongObjects.push_front(s)
		%CurrentlyLoading.text = "Finished loading "+song
	
	%CurrentlyLoading.text = "Loading Completed"
	$Loading.visible = false
	ChangeID(1)

	

func _input(event:InputEvent):
	if event is InputEventKey and inputEnabled:
		if event.is_action_released("ui_down"):
			ChangeID(-1)
		if event.is_action_released("ui_up"):
			ChangeID(1)
		
		if event.is_action_released("ui_accept"):
			SelectSong()

func ChangeID(amount):
	curSel = wrapi(curSel+amount, 0, SongList.size())
	
	# Extra functionality
	for obj in SongObjects: obj.Unselected()
	UpdateInformation(SongList[curSel])
	$SelectedHighlight.modulate.a = 0.0
	SongObjects[curSel].Selected()

func SelectSong():
	Utils.NextSongToPlay = SongList[curSel].get("RawName")
	get_tree().change_scene_to_file("res://src/Gameplay/main.tscn")

func UpdateInformation(data):
	%Name.text = WaveTextBBCode+data.get("Name")
	%Artist.text = WaveTextBBCode+data.get("Artist")
	%Mapper.text = WaveTextBBCode+data.get("Mapper")
	%Icon.texture = data.get("Cover", Utils.MissingIcon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt: float):
	$SelectedHighlight.position.y = SongObjects[curSel].position.y
	$SelectedHighlight.modulate.a = lerp($SelectedHighlight.modulate.a, 1.0, 12.0*dt)
	%IconContainer.rotation = sin(deg_to_rad(Time.get_ticks_msec() * 0.2)) * 0.08
	%IconShadow.rotation = %IconContainer.rotation
	for child in $SongList.get_children():
		child.position.y = lerp(child.position.y, child.size.y+100*child.ID, 12*dt)

func _input_enable() -> void:
	inputEnabled = true

func _on_options_pressed() -> void:
	var twn = create_tween()
	twn.tween_property(Overlay.get_node("Fade"), "color", Color.BLACK, 0.8).from(Color(0,0,0,0))
	twn.finished.connect(func():get_tree().change_scene_to_file("uid://krri1aoirckl"))

func _on_issue_report_pressed() -> void:
	$UserFeedbackGUI.visible = true
	inputEnabled = false

func _on_user_feedback_gui_visibility_changed() -> void:
	if not $UserFeedbackGUI.visible: _input_enable()

func _on_quit_pressed() -> void:
	get_tree().quit(0)
