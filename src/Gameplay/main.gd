extends Node2D

var ChartParser = load("res://src/Globals/ChartParser.gd")

var Playfield = preload("res://src/Gameplay/Playfield.tscn")
@onready var Camera = get_node("Cam")

@export var toload = "spaceoddity"
var chartdata = {}

func _ready() -> void:
	var rawchart = FileAccess.open("res://Songs/"+toload+"/chart.hdc", FileAccess.READ)
	chartdata = ChartParser.ParseCustomChart(rawchart.get_as_text())
	# Playfield
	var pf = Playfield.instantiate()
	pf.setup(chartdata)
	pf.name = "Playfield"
	$Playfields.add_child(pf)
	
	if FileAccess.file_exists("res://Songs/"+toload+"/effects.json"):
		Log.pr("Found an effect file!")
		var file = FileAccess.open("res://Songs/"+toload+"/effects.json", FileAccess.READ)
		var raw = JSON.parse_string(file.get_as_text())
		$EffectHandler.Setup(raw)
	else:
		Log.pr("Cannot find an effect file, skipping!")
	
	Conductor.BPM = 175.0
	Conductor.stream = load("res://Songs/spaceoddity/ARForest - Space Oddity.mp3")
	
	Conductor.play()

func _physics_process(_delta: float) -> void:
	for playfield in $Playfields.get_children():
		playfield.song_position = Conductor.curBeat
