extends Control

var SongObject = preload("res://src/Menus/Song.tscn")
var WaveTextBBCode = "[wave amp=60.0 freq=2.0 connected=0]"

var SongList = []
var SongObjects = []

var curSel = -1

func _ready() -> void:
	var list = DirAccess.get_directories_at("res://Songs/")
	var i = -1
	for song in list:
		%CurrentlyLoading.text = "Currently loading "+song
		var file = FileAccess.open("res://Songs/"+song+"/meta.txt", FileAccess.READ)
		var raw = file.get_as_text()
		var data = raw.split(":")
		var dict = {
			"RawName" = song,
			"Name" = data[0],
			"Cover" = data[1],
			"BPM" = float(data[2]),
			"PreviewTime" = float(data[3]),
			"AudioFile" = data[4],
			"Artist" = data[5],
			"Mapper" = data[6]
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
	if event is InputEventKey:
		if event.is_action_released("ui_down"):
			ChangeID(1)
		if event.is_action_released("ui_accept"):
			ChangeID(-1)
		
		if event.is_action_released("ui_accept"):
			SelectSong()

func ChangeID(amount):
	curSel = wrapi(amount, 0, SongList.size()-1)
	UpdateInformation(SongList[curSel])
	SongObjects[curSel].Selected()

func SelectSong():
	Utils.NextSongToPlay = SongList[curSel].get("RawName")
	get_tree().change_scene_to_file("res://src/Gameplay/main.tscn")

func UpdateInformation(data):
	%Name.text = WaveTextBBCode+data.get("Name")
	%Artist.text = WaveTextBBCode+data.get("Artist")
	%Mapper.text = WaveTextBBCode+data.get("Mapper")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	for child in $SongList.get_children():
		@warning_ignore("integer_division")
		child.position.y = (720/2)+15*child.ID
