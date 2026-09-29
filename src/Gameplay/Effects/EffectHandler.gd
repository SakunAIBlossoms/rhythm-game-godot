extends CanvasLayer

var FlashNode = preload("res://src/Gameplay/Effects/Flash.tscn")

var tweenlist = []

@onready var ShadeP = $Shaders

@onready var ShaderNodes = {
	"Retro" = ShadeP.get_node("Retro"),
	"Bloom" = ShadeP.get_node("Bloom"),
	"Vignette" = ShadeP.get_node("Vignette")
}

var Effects = {
	flash = [],
	layerfade = [],
	shader = [],
	beatpulse = [],
	scroll_multiply = [],
	loops = []
}

func sort_descending(a, b):
	if a.get("time") > b.get("time"):
		return true
	return false

func Setup(sent):
	Log.pr("Parsing the data")
	for obj in sent:
		match(obj):
			"flash": for o in sent[obj]:
				var newflash = FlashClass.new()
				newflash.setup(o)
				Effects.flash.push_front(newflash)
			"layerfade": for o in sent[obj]:
				Effects.layerfade.push_back(o)
			"beatpulse": for o in sent[obj]:
				var newpulse = BeatPulseClass.new()
				newpulse.setup(o)
				Effects.beatpulse.push_front(newpulse)
			"shader": for o in sent[obj]:
				var newshader = ShaderClass.new()
				newshader.setup(o)
				Effects.shader.push_front(newshader)

func _physics_process(_delta: float) -> void:
	for flash in Effects.flash:
		if int(Conductor.songPosition) >= int(flash.time) and flash.Triggered == false:
			Log.pr("Flashed at "+str(int(Conductor.songPosition)))
			_flashScreen(flash)
			flash.Triggered = true
	
	for pulse in Effects.beatpulse:
		if int(Conductor.songPosition) >= int(pulse.time) and pulse.Triggered == false:
			Log.pr("Updating beatpulse at "+str(int(Conductor.songPosition)))
			Utils.CurrentPulse = pulse
			pulse.Triggered = true
	
	for shader in Effects.shader:
		if int(Conductor.songPosition) >= int(shader.time) and shader.Triggered == false:
			if ShaderNodes.get(shader.shader, null) != null:
				Log.pr("Updating values for "+shader.shader+" shader at "+str(int(Conductor.songPosition))+" from value "+str(shader.startparams.x)+" to value "+str(shader.endparams.x))
				ShaderNodes.get(shader.shader, null).UpdateShader(shader.duration, shader.usestart, shader.startparams, shader.endparams, shader.transease)
			else: Log.pr("Cannot find "+shader.shader)
			shader.Triggered = true

func _flashScreen(flash):
	var newnode = FlashNode.instantiate()
	$Flashes.add_child(newnode)
	tweenlist.push_front(newnode.Flash(flash.duration, flash.startcolour, flash.endcolour, flash.transease))

class ShaderClass:
	var time := 0.0
	var duration := 0.0
	var shader := ""
	var transease := 0
	var startparams := Vector3(0,0,0)
	var endparams := Vector3(0,0,0)
	var usestart := false
	var Triggered := false
	
	func setup(data:Dictionary) -> void:
		self.time = data.get("time")
		self.duration = data.get("duration")
		self.shader = data.get("shader")
		self.transease = data.get("ease")
		self.usestart = data.get("use-start")
		
		if usestart:
			var tempstartparams = data.get("start-params")
			self.startparams = Vector3(tempstartparams.get("strength") if shader != "Vignette" else 1.0-tempstartparams.get("strength"), tempstartparams.get("strength2"), tempstartparams.get("strength3"))
		
		var tempendparams = data.get("end-params")
		self.endparams = Vector3(tempendparams.get("strength") if shader != "Vignette" else 1.0-tempendparams.get("strength"), tempendparams.get("strength2"), tempendparams.get("strength3"))

class BeatPulseClass:
	var time := 0.0
	var strength := 0.0
	var zoom := 0.0
	var interval := 0.0
	var Triggered := false
	
	func setup(data:Dictionary) -> void:
		self.time = data.get("time")
		self.strength = data.get("strength")
		self.zoom = data.get("zoom") if data.get("zoom") > 0.0 else 1
		self.interval = data.get("interval")

class FlashClass:
	var duration := 0.0
	var time := 0.0
	var startcolour := Color(1,1,1,1)
	var endcolour := Color(1,1,1,1)
	var transease := 0
	var Triggered := false
	
	func setup(data:Dictionary) -> void:
		self.duration = data.get("duration") / 1000
		self.time = data.get("time")
		self.startcolour = Color(data.get("start-color").get("R"), data.get("start-color").get("G"), data.get("start-color").get("B"), data.get("start-alpha"))
		self.endcolour = Color(data.get("end-color").get("R"), data.get("end-color").get("G"), data.get("end-color").get("B"), data.get("end-alpha"))
		self.transease = data.get('ease')
