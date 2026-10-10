extends CanvasLayer

var FlashNode = preload("res://src/Gameplay/Effects/Flash.tscn")

var tweenlist = []

@onready var ShadeP = $Shaders

@onready var ShaderNodes = {
	"Retro" = ShadeP.get_node("Retro"),
	"Bloom" = ShadeP.get_node("Bloom"),
	"Vignette" = ShadeP.get_node("Vignette"),
	"FishEye" = ShadeP.get_node("Fisheye"),
	"Chromatic" = ShadeP.get_node("Chromatic"),
	"Glitch" = ShadeP.get_node("Glitch"),
	"Reflections" = ShadeP.get_node("Reflections"),
	"SplitScreen" = ShadeP.get_node("SplitScreen"),
	"Glitch2" = ShadeP.get_node("Glitch2"),
	"HueShift" = ShadeP.get_node("HueShift"),
	"Greyscale" = ShadeP.get_node("Greyscale")
}

var playfields:Array

var Camera:Camera2D

var Effects = {
	flash = [],
	layerfade = [],
	shader = [],
	beatpulse = [],
	scroll_multiply = [],
	loops = [],
	playfieldmove = [],
	playfieldrotate = [],
	playfieldscale = [],
	camera_move = [],
	camera_scale = [],
	camera_rotation = []
}

func sort_descending(a, b):
	if a.get("time") > b.get("time"):
		return true
	return false

func Setup(sent, pfs, cam):
	Camera = cam
	playfields = pfs
	Log.pr("Parsing the data")
	for obj in sent:
		match(obj):
			"flash": for o in sent[obj]:
				var newflash = FlashClass.new()
				newflash.setup(o)
				Effects.flash.push_front(newflash)
			"layerfade": for o in sent[obj]:
				var newfade = LayerFadeClass.new()
				newfade.setup(o)
				Effects.layerfade.push_back(newfade)
			"beatpulse": for o in sent[obj]:
				var newpulse = BeatPulseClass.new()
				newpulse.setup(o)
				Effects.beatpulse.push_front(newpulse)
			"shader": for o in sent[obj]:
				var newshader = ShaderClass.new()
				newshader.setup(o)
				Effects.shader.push_front(newshader)
			"playfieldmove": for o in sent[obj]:
				var newmovement = PlayfieldMoveClass.new()
				newmovement.setup(o)
				newmovement.setup2(playfields[o.get("playfield")])
				Effects.playfieldmove.push_front(newmovement)
			"playfieldrotate": for o in sent[obj]:
				var newrotation = PlayfieldRotateClass.new()
				newrotation.setup(o)
				Effects.playfieldrotate.push_front(newrotation)
			"playfieldscale": for o in sent[obj]:
				var newscale = PlayfieldScaleClass.new()
				newscale.setup(o)
				Effects.playfieldscale.push_front(newscale)
			"camera-move": for o in sent[obj]:
				var newmovement = CameraMoveClass.new()
				newmovement.setup(o)
				Effects.camera_move.push_front(newmovement)
			"camera-scale": for o in sent[obj]:
				var newzoom = CameraZoomClass.new()
				newzoom.setup(o)
				Effects.camera_scale.push_front(newzoom)
			"camera-rotate": for o in sent[obj]:
				var newrotation = CameraRotateClass.new()
				newrotation.setup(o)
				Effects.camera_rotation.push_front(newrotation)
			"notes": pass
			_:
				print("I don't know what effect %s is, is this something new perhaps?" % obj)

func TogglePauseState(state:bool):
	if state:
		Log.pr("Pausing all tweens to pause the game.")
		for twn in tweenlist:
			if twn.is_valid():
				twn.pause()
			else:
				Log.pr("Tween has already ended and cannot be paused again, skipping...")
	else:
		Log.pr("Resuming all tweens to unpause the game.")
		for twn in tweenlist:
			if twn.is_valid():
				twn.play()
			else:
				Log.pr("Tween has already ended and should not be restarted, skipping...")
		

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
				tweenlist.push_front(ShaderNodes.get(shader.shader, null).UpdateShader(shader.duration, shader.usestart, shader.startparams, shader.endparams, shader.transease))
			else: Log.pr("Cannot find "+shader.shader)
			shader.Triggered = true
	
	for rotationtodo in Effects.playfieldrotate:
		if int(Conductor.songPosition) >= int(rotationtodo.time) and rotationtodo.Triggered == false:
			tweenlist.push_front(_rotateplayfield(rotationtodo.duration, rotationtodo.roll, rotationtodo.playfield, rotationtodo.subfield, rotationtodo.easing))
			rotationtodo.Triggered = true
	
	for fade in Effects.layerfade:
		if int(Conductor.songPosition) >= int(fade.time) and fade.Triggered == false:
			tweenlist.push_front(_layerfade(fade.duration, fade.alpha, fade.mylayer, fade.playfield, fade.subfield, fade.easing))
			fade.Triggered = true
	
	for scaletodo in Effects.playfieldscale:
		if int(Conductor.songPosition) >= int(scaletodo.time) and scaletodo.Triggered == false:
			tweenlist.push_front(_scaleplayfield(scaletodo.duration, scaletodo.scale, scaletodo.playfield, scaletodo.subfield, scaletodo.easing))
			scaletodo.Triggered = true
	
	for movement in Effects.camera_move:
		if int(Conductor.songPosition) >= int(movement.time) and movement.Triggered == false:
			tweenlist.push_front(_cameramove(movement.duration, movement.position, movement.easing))
			movement.Triggered = true
	
	for zoom in Effects.camera_scale:
		if int(Conductor.songPosition) >= int(zoom.time) and zoom.Triggered == false:
			tweenlist.push_front(_scalecamera(zoom.duration, zoom.zoom, zoom.easing))
			zoom.Triggered = true
	
	for rotate in Effects.camera_rotation:
		if int(Conductor.songPosition) >= int(rotate.time) and rotate.Triggered == false:
			tweenlist.push_front(_camerarotate(rotate.duration, rotate.roll, rotate.easing))
			rotate.Triggered = true

func _flashScreen(flash):
	var newnode = FlashNode.instantiate()
	
	if flash.background:
		for child in $Flashes/Background.get_children():
			child.queue_free()
		$Flashes/Background.add_child(newnode)
	else:
		for child in $Flashes/Foreground.get_children():
			child.queue_free()
		$Flashes/Foreground.add_child(newnode)
	tweenlist.push_front(newnode.Flash(flash.duration, flash.startcolour, flash.endcolour, flash.transease))

@warning_ignore("unused_parameter")
func _scaleplayfield(duration:float, scaleto:Vector2, playfield:int, subfield:int, easing:int) -> Tween:
	var twn = create_tween()
	twn.set_ease(Utils.GetfluXisEasing(easing))
	twn.set_trans(Utils.GetfluXisTrans(easing))
	if subfield != 0: 
		var pf = playfields.get(subfield)
		twn.tween_property(pf, "scale", scaleto, duration)
	else:
		for field in playfields:
			twn.parallel().tween_property(field, "scale", scaleto, duration)
	
	return twn

@warning_ignore("unused_parameter")
func _rotateplayfield(duration:float, roll:float, playfield:int, subfield:int, easing:int) -> Tween:
	var twn = create_tween()
	twn.set_ease(Utils.GetfluXisEasing(easing))
	twn.set_trans(Utils.GetfluXisTrans(easing))
	if subfield != 0: 
		var pf = playfields.get(subfield)
		twn.tween_property(pf, "rotation_degrees", roll, duration)
	else:
		for field in playfields:
			twn.parallel().tween_property(field, "rotation_degrees", roll, duration)
	
	return twn

func _cameramove(duration:float, position:Vector2, easing:int) -> Tween:
	var twn = create_tween()
	twn.set_ease(Utils.GetfluXisEasing(easing))
	twn.set_trans(Utils.GetfluXisTrans(easing))
	twn.tween_property(Camera, "offset", position, duration)
	
	return twn

func _camerarotate(duration:float, roll:float, easing:int) -> Tween:
	var twn = create_tween()
	twn.set_ease(Utils.GetfluXisEasing(easing))
	twn.set_trans(Utils.GetfluXisTrans(easing))
	twn.tween_property(Camera, "rotation_degrees", roll, duration)
	
	return twn

@warning_ignore("unused_parameter")
func _moveplayfield(duration:float, position:Vector3, playfield:int, subfield:int, easing:int) -> Tween:
	var twn = create_tween()
	twn.set_ease(Utils.GetfluXisEasing(easing))
	twn.set_trans(Utils.GetfluXisTrans(easing))
	if subfield != 0: 
		var pf = playfields.get(subfield)
		twn.tween_property(pf, "position", position, duration)
	else:
		for field in playfields:
			twn.parallel().tween_property(field, "position", position, duration)
	
	return twn

@warning_ignore("unused_parameter")
func _layerfade(duration:float, alpha:float, playfield:int, coollayer:int, subfield:int, easing:int) -> Tween:
	var twn = create_tween()
	twn.set_ease(Utils.GetfluXisEasing(easing))
	twn.set_trans(Utils.GetfluXisTrans(easing))
	match(coollayer):
		3:
			if subfield != 0: 
				var pf = playfields.get(subfield)
				twn.tween_property(pf, "modulate:a", alpha, duration)
			else:
				for field in playfields:
					twn.parallel().tween_property(field, "modulate:a", alpha, duration)
		4:
			pass
		_: Log.pr("Layer %s ill not be implemented right now." % str(coollayer))
	
	return twn

func _scalecamera(duration:float, zoom:float, easing:int) -> Tween:
	var twn = create_tween()
	twn.set_ease(Utils.GetfluXisEasing(easing))
	twn.set_trans(Utils.GetfluXisTrans(easing))
	twn.tween_property(Camera, "BaseCamZoom", Vector2(zoom, zoom), duration)
	
	return twn

@abstract class BaseEffectClass:
	var time := 0.0
	var Triggered := false
	
	@abstract func setup(data:Dictionary) -> void

class CameraZoomClass extends BaseEffectClass:
	var zoom := 0.0
	var duration := 0.0
	var easing := 0
	
	func setup(data) -> void:
		self.time = data.get("time")
		self.duration = data.get("duration")
		self.easing = data.get("ease")
		self.zoom = data.get("scale")

class CameraRotateClass extends BaseEffectClass:
	var roll := 0.0
	var duration := 0.0
	var easing := 0
	
	func setup(data) -> void:
		self.time = data.get("time")
		self.duration = data.get("duration")
		self.easing = data.get("ease")
		self.roll = data.get("roll")

class CameraMoveClass extends BaseEffectClass:
	var position := Vector2(0,0)
	var duration := 0.0
	var easing := 0
	
	func setup(data) -> void:
		self.time = data.get("time")
		self.duration = data.get("duration")
		self.easing = data.get("ease")
		self.position = Vector2(data.get("x"), data.get("y"))

class ShaderClass extends BaseEffectClass:
	var duration := 0.0
	var shader := ""
	var transease := 0
	var startparams := Vector3(0,0,0)
	var endparams := Vector3(0,0,0)
	var usestart := false
	
	func setup(data:Dictionary) -> void:
		self.time = data.get("time")
		self.duration = data.get("duration") / 1000
		self.shader = data.get("shader")
		self.transease = data.get("ease")
		self.usestart = data.get("use-start")
		
		if usestart:
			var tempstartparams = data.get("start-params")
			self.startparams = Vector3(tempstartparams.get("strength") if shader != "Vignette" or shader != "FishEye" else 1.0-tempstartparams.get("strength"), tempstartparams.get("strength2"), tempstartparams.get("strength3"))
		
		var tempendparams = data.get("end-params")
		self.endparams = Vector3(tempendparams.get("strength") if shader != "Vignette" or shader != "FishEye" else 1.0-tempendparams.get("strength"), tempendparams.get("strength2"), tempendparams.get("strength3"))

class PlayfieldMoveClass extends BaseEffectClass:
	var position := Vector3(0.0,0.0,0.0)
	var duration := 0.0
	var easing := 0
	var playfield := 0
	var subfield := 0
	
	func setup(data:Dictionary) -> void:
		self.time = data.get("time")
		self.position = Vector3((data.get("x", 0.0)/2.0), (720.0/2.0) + (data.get("y", 0.0)/2.0), data.get("Z", 0.0))
		self.duration = data.get("duration") / 1000
		self.easing = data.get("ease")
		self.playfield = data.get("playfield")
		self.subfield = data.get("subfield")
	
	func setup2(pf) -> void:
		self.position.x = ((1280.0/2.0) - (pf.size.x/2.0)) + self.position.x

class LayerFadeClass extends BaseEffectClass:
	var duration := 0.0
	var alpha := 1.0
	var easing := 0
	var mylayer := 0
	var playfield := 0
	var subfield := 0
	
	func setup(data:Dictionary) -> void:
		self.time = data.get("time")
		self.duration = data.get("duration")
		self.alpha = data.get("alpha")
		self.easing = data.get("ease")
		self.mylayer = data.get("layer")
		self.playfield = data.get("playfield")
		self.subfield = data.get("subfield")

class PlayfieldRotateClass extends BaseEffectClass:
	var roll := 0.0
	var duration := 0.0
	var easing := 0
	var playfield := 0
	var subfield := 0
	
	func setup(data:Dictionary) -> void:
		self.time = data.get("time")
		self.roll = data.get("roll")
		self.duration = data.get("duration") / 1000
		self.easing = data.get("ease")
		self.playfield = data.get("playfield")
		self.subfield = data.get("subfield")

class PlayfieldScaleClass extends BaseEffectClass:
	var scale := Vector2(1.0,1.0)
	var duration := 0.0
	var easing := 0
	var playfield := 0
	var subfield := 0
	
	func setup(data:Dictionary) -> void:
		self.time = data.get("time")
		self.scale = Vector2(data.get("x"), data.get("y"))
		self.duration = data.get("duration") / 1000
		self.easing = data.get("ease")
		self.playfield = data.get("playfield")
		self.subfield = data.get("subfield")

class BeatPulseClass extends BaseEffectClass:
	var strength := 0.0
	var zoom := 0.0
	var interval := 0
	
	func setup(data:Dictionary) -> void:
		self.time = data.get("time")
		self.strength = data.get("strength")
		self.zoom = data.get("zoom")
		self.interval = data.get("interval") if data.get("interval") > 0 else 999

class FlashClass extends BaseEffectClass:
	var duration := 0.0
	var background := false
	var startcolour := Color(1,1,1,1)
	var endcolour := Color(1,1,1,1)
	var transease := 0
	
	func setup(data:Dictionary) -> void:
		self.duration = data.get("duration") / 1000
		self.time = data.get("time")
		self.startcolour = Color(data.get("start-color").get("R"), data.get("start-color").get("G"), data.get("start-color").get("B"), data.get("start-alpha"))
		self.endcolour = Color(data.get("end-color").get("R"), data.get("end-color").get("G"), data.get("end-color").get("B"), data.get("end-alpha"))
		self.transease = data.get('ease')
		self.background = data.get("background")
