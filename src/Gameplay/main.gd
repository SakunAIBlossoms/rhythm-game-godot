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

var ScoreData:PlayerStatistics

var health:float = 100

func _ready():
	ScoreData = PlayerStatistics.new()
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
	
	Log.pr("Checking for video background")
	if FileAccess.file_exists("res://Songs/"+Utils.NextSongToPlay+"/videobg.mp4"):
		Log.pr("Video background found")
		if Config.GetOption("VideoBackgroundEnabled") == false:
			Log.pr("Video background disabled in options, destroying node...")
			$VideoBackground.queue_free()
		else:
			Log.pr("Loading video...")
			$VideoBackground.open("res://Songs/"+Utils.NextSongToPlay+"/videobg.mp4")
			Log.pr("Video loaded!")
	else:
		# Cant find it so we delete it to save space.
		Log.pr("Couldn't find video file, destroying node.")
		$VideoBackground.queue_free()
		
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
		for lane in pf.get_children():
			lane.Hit.connect(_hit)
			lane.Missed.connect(_miss)
		
		Log.pr("Playfield ", pf, " setup complete.")
		
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

		Log.pr("Setup pause")
		$Pause.Setup(data[1])
		Log.pr("Pause setup complete")
	else:
		Log.error("Cannot find the metadata file")
	
	# Updating all positions just in-case
	Log.pr("Begin updating playfield positions to defaults.")
	for playfield in $Gameplay/Playfields.get_children():
		@warning_ignore("integer_division")
		playfield.position.x = (1280/2) - (playfield.size.x/2)
		Log.pr("Updated ", playfield, " x position to ", playfield.position.x)
	
	if Config.GetOption("VisualEffectsEnabled") == false:
		Log.pr("User disabled visual effects, skipping creation and destroying the effect node for performance.")
		$EffectHandler.queue_free()
	else:
		Log.pr("Checking for visual effects file")
		if FileAccess.file_exists("res://Songs/"+Utils.NextSongToPlay+"/effects.json"):
			Log.pr("Found an effect file!")
			var file = FileAccess.open("res://Songs/"+Utils.NextSongToPlay+"/effects.json", FileAccess.READ)
			var raw = JSON.parse_string(file.get_as_text())
			$EffectHandler.Setup(raw, playfields, Camera)
			Conductor.Beat.connect(BeatHit)
		else:
			Log.pr("Cannot find an effect file, skipping!")
			$EffectHandler.queue_free()
	
	Conductor.finished.connect(_song_finished)

	$"3SecondIntroTimer".start(3.0)

func _hit(rating:String, delay:float):
	if health < 100: health += 3
	ScoreData.NotesHit += 1
	$HUD/Hit.text = rating
	$HUD/Hit/delay.text = str(roundi(delay))+"ms"
	
	var twn = create_tween().set_parallel(true)
	twn.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	twn.tween_property($HUD/Hit, "modulate:a", 1, 0.4).from(0.0)
	twn.tween_property($HUD/Hit, "scale", Vector2(1.0,1.0), 0.4).from(Vector2(0.8,0.8))
	twn.tween_property($HUD/Hit/delay, "position:y", 50.0, 0.4).from(12.0)
	
	match(rating):
		"Perfect":
			ScoreData.Perfects += 1
		"Good":
			ScoreData.Goods += 1
		"Bad":
			ScoreData.Bads += 1

func _miss():
	ScoreData.Misses += 1
	if health > 0: health -= 5

func BeatHit(beat):
	if Utils.CurrentPulse != null:
		if int(Utils.CurrentPulse.interval) != 0:
			if beat % int(Utils.CurrentPulse.interval) == 0:
				Camera.zoom += Vector2((Utils.CurrentPulse.zoom/10), (Utils.CurrentPulse.zoom/10))

func _input(event:InputEvent):
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == Key.KEY_ESCAPE and not Paused:
			TogglePause()
		
		if event.keycode == Key.KEY_9 and event.is_released():
			Utils.autoplay = not Utils.autoplay

func TogglePause():
	Paused = not Paused
	
	if get_node("EffectHandler") != null: $EffectHandler.TogglePauseState(Paused)
	if (Paused):
		$Pause.Pause()
		if get_node("VideoBackground") != null: $VideoBackground.pause()
	else:
		if get_node("VideoBackground") != null: $VideoBackground.play()
	Conductor.stream_paused = Paused

func _process(dt:float):
	if Utils.CurrentPulse != null: Camera.zoom = lerp(Camera.zoom, Camera.BaseCamZoom, (12*Utils.CurrentPulse.strength)*dt)
	else: Camera.zoom = lerp(Camera.zoom, Camera.BaseCamZoom, 12*dt)
	if $"3SecondIntroTimer".time_left > 0: $Overlay/Countdown.text = str(int($"3SecondIntroTimer".time_left+1))
	else: $Overlay/Countdown.visible = false
	$Overlay/AutoplayText.visible = Utils.autoplay
	if health <= 0: 
		$HUD/Health/Fail.visible = true
	else:
		$HUD/Health.set_value_no_signal(lerp($HUD/Health.value, health, 12*dt))
	
	if $HUD/Health/Fail.visible: $HUD/Health.set_value_no_signal(0.)

func _song_finished():
	# Replace this with a score screen later.
	if not $HUD/Health/Fail.visible: Utils.PlayerCurrentScore = ScoreData
	else: Utils.PlayerCurrentScore = null
	get_tree().change_scene_to_file("res://src/Menus/scoreboard.tscn")

class PlayerStatistics:
	var Misses := 0
	var NotesHit := 0
	var Accuracy := "100%"
	var Perfects := 0
	var Goods := 0
	var Bads := 0

func _on_second_intro_timer_timeout():
	Conductor.play()
	Utils.DoTweenProperty($Overlay/Background, "color:a", 0.0, 0.8, Tween.EASE_OUT, Tween.TRANS_CIRC)
	if get_node("VideoBackground") != null: $VideoBackground.play_from_start()

func _on_pause_unpause() -> void:
	TogglePause()
