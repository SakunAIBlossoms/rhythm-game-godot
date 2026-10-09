extends Node2D

var ChartParser = load("res://src/Globals/ChartParser.gd")

var Playfield = preload("res://src/Gameplay/Playfield.tscn")
@onready var Camera = get_node("Cam")
var chartdata = {}

var pulse

@onready var CustomScripts

var Scripts:Array = []

var playfields = []

func _ready():
	
	var rawchart = FileAccess.open("res://Songs/"+Utils.NextSongToPlay+"/chart.hdc", FileAccess.READ)
	chartdata = ChartParser.ParseCustomChart(rawchart.get_as_text())
	
	if FileAccess.file_exists("res://Songs/"+Utils.NextSongToPlay+"/meta.txt"):
		var file = FileAccess.open("res://Songs/"+Utils.NextSongToPlay+"/meta.txt", FileAccess.READ)
		var raw = file.get_as_text()
		var data = raw.split(":")
		
		if float(data[2]) == null: Log.error("Failed to parse BPM")
		else: Conductor.BPM = float(data[2])
		if data[4] == null: Log.error("Failed to parse song file location")
		else: Conductor.stream = load("res://Songs/"+Utils.NextSongToPlay+"/"+data[4])
		
		# Playfield
		var pf = Playfield.instantiate()
		pf.Keycount = int(data[8])
		pf.setup(chartdata, false)
		pf.name = "Playfield"
		$Gameplay.add_child(pf)
		playfields.push_front($"Gameplay/Playfields/1")
		$"Gameplay/Playfields/1".texture = pf.get_texture()
		$"Gameplay/Playfields/1".size = pf.size
		
		if int(data[7]) > 0:
			for i in int(data[7]):
				var fakepf = $"Gameplay/Playfields/1".duplicate()
				fakepf.name = str(i+1)
				playfields.push_front(fakepf)
				$Gameplay/Playfields.add_child(fakepf)
				fakepf.modulate.a = 0
	else:
		Log.error("Cannot find the metadata file")
	
	for playfield in $Gameplay/Playfields.get_children():
		@warning_ignore("integer_division")
		playfield.position.x = (1280/2) - (playfield.size.x/2)
		
	if FileAccess.file_exists("res://Songs/"+Utils.NextSongToPlay+"/effects.json"):
		Log.pr("Found an effect file!")
		var file = FileAccess.open("res://Songs/"+Utils.NextSongToPlay+"/effects.json", FileAccess.READ)
		var raw = JSON.parse_string(file.get_as_text())
		$EffectHandler.Setup(raw, playfields, Camera)
		#Conductor.Beat.connect(BeatHit)
	else:
		Log.pr("Cannot find an effect file, skipping!")
	
	Conductor.play()

func BeatHit(beat):
	if Utils.CurrentPulse != null:
		if roundi(Utils.CurrentPulse.interval) != 0 and Utils.CurrentPulse.zoom != 0.0:
			if beat % roundi(Utils.CurrentPulse.interval) == 0:
				Camera.zoom += Vector2((Utils.CurrentPulse.zoom/10), (Utils.CurrentPulse.zoom/10))

func _process(dt:float):
	if Utils.CurrentPulse != null: if roundi(Utils.CurrentPulse.interval) != 0 and Utils.CurrentPulse.zoom != 0.0: Camera.zoom = lerp(Camera.zoom, Vector2(1.0, 1.0), (12*Utils.CurrentPulse.strength)*dt)


#func _unhandled_key_input(event: InputEvent) -> void:
#	print(event.as_text())
#	for pf in playfields:
#		for lane in pf.get_children():
#			if Config.Binds[lane.ID].to_upper() == event.as_text() and event.is_pressed():
#				lane.HitNote()
#			if Config.Binds[lane.ID].to_upper() == event.as_text() and event.is_released():
#				lane.LetGo()
