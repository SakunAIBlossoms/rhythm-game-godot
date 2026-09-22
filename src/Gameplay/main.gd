extends Node2D

var ChartParser = load("res://src/Globals/ChartParser.gd")

var Playfield = preload("res://src/Gameplay/Playfield.tscn")
@onready var Camera = get_node("Cam")
var chartdata = {}

var playfields = []

func _ready():
	var rawchart = FileAccess.open("res://Songs/"+Utils.NextSongToPlay+"/chart.hdc", FileAccess.READ)
	chartdata = ChartParser.ParseCustomChart(rawchart.get_as_text())
	# Playfield
	var pf = Playfield.instantiate()
	pf.setup(chartdata)
	pf.name = "Playfield"
	playfields.push_back(pf)
	$Playfields.add_child(pf)
	
	if FileAccess.file_exists("res://Songs/"+Utils.NextSongToPlay+"/effects.json"):
		Log.pr("Found an effect file!")
		var file = FileAccess.open("res://Songs/"+Utils.NextSongToPlay+"/effects.json", FileAccess.READ)
		var raw = JSON.parse_string(file.get_as_text())
		$EffectHandler.Setup(raw)
	else:
		Log.pr("Cannot find an effect file, skipping!")
	
	if FileAccess.file_exists("res://Songs/"+Utils.NextSongToPlay+"/meta.txt"):
		var file = FileAccess.open("res://Songs/"+Utils.NextSongToPlay+"/meta.txt", FileAccess.READ)
		var raw = file.get_as_text()
		var data = raw.split(":")
		if float(data[2]) == null: Log.error("Failed to parse BPM")
		else: Conductor.BPM = float(data[2])
		if data[4] == null: Log.error("Failed to parse song file location")
		else: Conductor.stream = load("res://Songs/"+Utils.NextSongToPlay+"/"+data[4])
	else:
		Log.error("Cannot find the metadata file")
	
	Conductor.play()

#func _unhandled_key_input(event: InputEvent) -> void:
#	print(event.as_text())
#	for pf in playfields:
#		for lane in pf.get_children():
#			if Config.Binds[lane.ID].to_upper() == event.as_text() and event.is_pressed():
#				lane.HitNote()
#			if Config.Binds[lane.ID].to_upper() == event.as_text() and event.is_released():
#				lane.LetGo()
