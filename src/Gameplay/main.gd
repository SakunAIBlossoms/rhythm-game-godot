extends Node2D

var ChartParser = load("res://src/Globals/ChartParser.gd")

@export var toload = "spaceoddity"
var chartdata = {}

func _ready() -> void:
	var raw = FileAccess.open("res://Songs/"+toload+"/chart.hdc", FileAccess.READ)
	var parsed = ChartParser.ParseCustomChart(raw.get_as_text())
	chartdata = ChartParser.GetLanes()
