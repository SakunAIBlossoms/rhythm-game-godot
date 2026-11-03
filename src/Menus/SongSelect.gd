extends Control

var SongObject = preload("res://src/Menus/Song.tscn")
var WaveTextBBCode = "[wave amp=60.0 freq=2.0 connected=0]"

var SongList = []
var SongObjects = []

var inputEnabled = false

var curSel = -1

func _ready() -> void:
	if Config.GetOption("GraphicsShadersEnabled") == false: $BG/Shader.queue_free()
	
	Utils.NextSongToPlay = ""
	Utils.CurrentPulse = null
	Utils.CurrentKeycount = 4
	Utils.PlayerCurrentScore = null

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
			"RawName" = song, # name of the folder that the song is in.
			"Name" = data[0], # name of the song proper, this one gets shown to the player
			"Cover" = load("res://Songs/"+song+"/"+data[1]), # texture data of the cover art
			"BPM" = float(data[2]), # beats per minute for the song
			"PreviewTime" = float(data[3]), # what time in milliseconds does the song preview from when hovered
			"AudioFile" = data[4], # name of the file that contains the song, this only gets used once which is why I don't load it.
			"Artist" = data[5], # just some text containing the name of the artist who made the song.
			"Mapper" = data[6], # some credit for the person who mapped the notes for the song.
			"ExtraPlayfields" = data[7], # how many extra playfields will it have? *UNUSED*
			"Keycount" = data[8], # the amount of keys this song has.
			"HasEffects" = FileAccess.file_exists("res://Songs/"+song+"/effects.json"), # Whether visual effects are present for this song.
			"HasVideoBG" = FileAccess.file_exists(OS.get_executable_path().get_base_dir()+"/Videos/"+song+".mp4") if not OS.is_debug_build() else FileAccess.file_exists("res://Videos/"+song+".mp4") # If a background can be found make sure to indicate that.
		}
		SongList.push_front(dict)
		
		var s = SongObject.instantiate()
		s.Setup(dict)
		s.ID = i
		s.get_node("Button").pressed.connect(func(): ForceSetID((list.size()-1) - s.ID))
		%SongList.add_child(s)
		SongObjects.push_front(s)
		%CurrentlyLoading.text = "Finished loading "+song
	
	%CurrentlyLoading.text = "Loading Completed"
	$Loading.visible = false
	ChangeID(randi_range(0,SongObjects.size()-1))

var viewport_size = Vector2(1280,720)

func _input(event:InputEvent):
	if event is InputEventKey and inputEnabled:
		if event.is_action_released("down"):
			ChangeID(-1)
		if event.is_action_released("up"):
			ChangeID(1)
		
		if event.is_action_released("ui_accept"):
			SelectSong()
	
	if event is InputEventMouseMotion:
		var mouse_x = event.position.x
		var mouse_y = event.position.y
		var relative_x = (mouse_x - (viewport_size.x/2)) / (viewport_size.x/2)
		var relative_y = (mouse_y - (viewport_size.y/2)) / (viewport_size.y/2)
		$BG.scroll_offset.x = 12 * relative_x
		$BG.scroll_offset.y = 12 * relative_y

func ForceSetID(ID:int):
	curSel = ID
	for obj in SongObjects: obj.Unselected()
	UpdateInformation(SongList[curSel])
	$SelectedHighlight.modulate.a = 0.0
	SongObjects[curSel].Selected()

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
	var vidbg = "Has video background" if data.get("HasVideoBG") else "Lacks video background"
	var effectstatus = "Has VFX" if data.get("HasEffects") else "Lacks VFX"
	%Information.text = WaveTextBBCode+data.get("Name")+"\n[font_size=16]"+data.get("Artist")+"\n"+data.get("Mapper")+"\nKeycount: "+data.get("Keycount")+"\n"+vidbg+"\n"+effectstatus
	%Icon.texture = data.get("Cover", Utils.MissingIcon)
	Utils.DoTweenProperty(%BackgroundImg, "modulate:a", 0.0, 0.2).finished.connect(func():
		%BackgroundImg.texture = load("res://Songs/"+data.get("RawName")+"/bgimg.png")
		Utils.DoTweenProperty(%BackgroundImg, "modulate:a", 1.0, 0.2)
		)
	
	var canUseVBG = Config.GetOption("VideoBackgroundEnabled") if typeof(Config.GetOption("VideoBackgroundEnabled")) else true
	var videofile = OS.get_executable_path().get_base_dir()+"/Videos/"+data.get("RawName")+".mp4" if not OS.is_debug_build() else "res://Videos/"+data.get("RawName")+".mp4"
	if data.get("HasVideoBG") and canUseVBG:
		%BackgroundVideo.visible = true
		%BackgroundVideo.open(videofile)
		%BackgroundVideo.play()
		%BackgroundVideo.seek(data.get("PreviewTime"))
	else:
		%BackgroundVideo.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt: float):
	$SelectedHighlight.position.y = SongObjects[curSel].global_position.y
	$SelectedHighlight.modulate.a = lerp($SelectedHighlight.modulate.a, 1.0, 12.0*dt)
	%IconContainer.rotation = sin(deg_to_rad(Time.get_ticks_msec() * 0.2)) * 0.08
	%IconShadow.rotation = %IconContainer.rotation
	#for child in $SongList.get_children():
	#	child.position.y = lerp(child.position.y, child.size.y+50*child.ID, 12*dt)

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
