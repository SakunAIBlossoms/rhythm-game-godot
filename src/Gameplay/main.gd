extends Node2D
@warning_ignore_start("incompatible_ternary")

var ChartParser = load("res://src/Globals/ChartParser.gd")

var Playfield = preload("res://src/Gameplay/PlayfieldNode.tscn")
@onready var Camera = get_node("Cam")
var chartdata = {}

var pulse

@onready var CustomScripts

var Scripts:Array = []

var playfields = []

var Paused:bool = false

var roundedvaluesfordebug = false

func _ready():

	# Conductor debug
	Log.pr("Setting up ImGui debug layer")
	ImGui.imgui_layout.connect(func():
		if Debug.FPSVisible:
			var curtime = Conductor.songPosition
			var curbeat = Conductor.curBeat
			var curstep = Conductor.curStep
			ImGui.set_next_window_size(250, 132, ImGuiApi.COND_ONCE)
			if ImGui.begin("Conductor Debug"):
				ImGui.text("Current Time: "+str(int(curtime) if roundedvaluesfordebug else curtime))
				ImGui.text("Current Beat: "+str(int(curbeat) if roundedvaluesfordebug else curbeat))
				ImGui.text("Current Step: "+str(int(curstep) if roundedvaluesfordebug else curstep))
				roundedvaluesfordebug = ImGui.checkbox("Round values?", roundedvaluesfordebug)
				if ImGui.button("Hide Conductor Debug", 0.0, 0.0):
					Debug.FPSVisible = false
			ImGui.end()
		)
	Log.pr("ImGui debug layer setup complete")

	Log.pr("Loading chart data")
	var rawchart = FileAccess.open("res://Songs/"+Utils.NextSongToPlay+"/chart.hdc", FileAccess.READ)
	chartdata = ChartParser.ParseCustomChart(rawchart.get_as_text())
	Log.pr("Chart loaded")
	
	if FileAccess.file_exists("res://Songs/"+Utils.NextSongToPlay+"/meta.txt"):
		Log.pr("Loading ", Utils.NextSongToPlay, " metadata")
		var file = FileAccess.open("res://Songs/"+Utils.NextSongToPlay+"/meta.txt", FileAccess.READ)
		var raw = file.get_as_text()
		var data = raw.split(":")
		Log.pr("Metadata loaded")

		Log.pr("Setting up playfields")
		Utils.CurrentKeycount = int(data[8])
		
		if float(data[2]) == null: Log.error("Failed to parse BPM")
		else: Conductor.BPM = float(data[2])
		if data[4] == null: Log.error("Failed to parse song file location")
		else: Conductor.stream = load("res://Songs/"+Utils.NextSongToPlay+"/"+data[4])

		$HUD/SongName.text = "[wave]Song: "+data[0]
		
		# Playfield
		var pf = Playfield.instantiate()
		pf.Keycount = int(data[8])
		pf.setup(chartdata, false)
		pf.name = "Playfield"
		$Gameplay/Playfields.add_child(pf)
		playfields.push_front(pf)
		#playfields.push_front($"Gameplay/Playfields/1")
		#$"Gameplay/Playfields/1".texture = pf.get_texture()
		#$"Gameplay/Playfields/1".size = pf.size
		
		#if int(data[7]) > 0:
		#	for i in int(data[7]):
		#		var fakepf = $"Gameplay/Playfields/1".duplicate()
		#		fakepf.name = str(i+1)
		#		playfields.push_front(fakepf)
		#		$Gameplay/Playfields.add_child(fakepf)
		#		fakepf.modulate.a = 0

		$Pause.Setup(data[1])
	else:
		Log.error("Cannot find the metadata file")
	
	for playfield in $Gameplay/Playfields.get_children():
		@warning_ignore("integer_division")
		playfield.position.x = (1280/2) - (playfield.size.x/2)
		
	if Config.GetOption("VisualEffectsEnabled") == false:
		Log.pr("User disabled visual effects, skipping creation and destroying the effect node for performance.")
		$EffectHandler.queue_free()
	else:
		if FileAccess.file_exists("res://Songs/"+Utils.NextSongToPlay+"/effects.json"):
			Log.pr("Found an effect file!")
			var file = FileAccess.open("res://Songs/"+Utils.NextSongToPlay+"/effects.json", FileAccess.READ)
			var raw = JSON.parse_string(file.get_as_text())
			$EffectHandler.Setup(raw, playfields, Camera)
			Conductor.Beat.connect(BeatHit)
		else:
			Log.pr("Cannot find an effect file, skipping!")
			$EffectHandler.queue_free()
	
	$"3SecondIntroTimer".start(3.0)

func BeatHit(beat):
	if Utils.CurrentPulse != null:
		if int(Utils.CurrentPulse.interval) != 0:
			if beat % int(Utils.CurrentPulse.interval) == 0:
				Camera.zoom += Vector2((Utils.CurrentPulse.zoom/10), (Utils.CurrentPulse.zoom/10))

func _input(event:InputEvent):
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == Key.KEY_ESCAPE and not Paused:
			TogglePause()

func TogglePause():
	Paused = not Paused
	
	$EffectHandler.TogglePauseState(Paused)
	if (Paused): $Pause.Pause()
	Conductor.stream_paused = Paused

func _process(dt:float):
	if Utils.CurrentPulse != null: Camera.zoom = lerp(Camera.zoom, Camera.BaseCamZoom, (12*Utils.CurrentPulse.strength)*dt)
	else: Camera.zoom = lerp(Camera.zoom, Camera.BaseCamZoom, 12*dt)
	if $"3SecondIntroTimer".time_left > 0: $Overlay/Countdown.text = str(int($"3SecondIntroTimer".time_left+1))
	else: $Overlay/Countdown.visible = false

func _song_finished():
	# Replace this with a score screen later.
	get_tree().change_scene_to_file("res://src/Menus/SongSelect.tscn")

class PlayerStatistics:
	var Misses := 0
	var NotesHit := 0
	var Accuracy := "100%"

func _on_second_intro_timer_timeout():
	Conductor.play()
	Utils.DoTweenProperty($Overlay/Background, "color:a", 0.0, 0.8, Tween.EASE_OUT, Tween.TRANS_CIRC)

func _on_pause_unpause() -> void:
	TogglePause()
