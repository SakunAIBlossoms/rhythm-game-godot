extends CanvasLayer

var BeatPulse = load("res://src/Gameplay/Effects/BeatPulse.gd")
@onready var Gameplay = self.get_parent()

var Effects = {
	flash = [],
	layerfade = [],
	shader = [],
	beatpulse = [],
	scroll_multiply = [],
	loops = []
}

func Setup(sent):
	Log.pr("Parsing the data")
	for obj in sent:
		match(obj):
			"flash": for o in sent[obj]: Effects.flash.push_back(o)
			"layerfade": for o in sent[obj]: Effects.layerfade.push_back(o)
			"beatpulse": for o in sent[obj]: Effects.beatpulse.push_back(o)
	
	BeatPulse.Setup(self)

func _physics_process(_delta: float) -> void:
	for flash in Effects.flash:
		if flash.get("time") != null and flash.get("time") > Conductor.songPosition and flash.get('time') < Conductor.songPosition + 1.0:
			Log.pr("Flash!")
			$Flash.Flash(flash.get("duration") / 1000, Color(flash.get("start-color").get("R"), flash.get("start-color").get("G"), flash.get("start-color").get("B"), flash.get("start-alpha")), Color(flash.get("end-color").get("R"), flash.get("end-color").get("G"), flash.get("end-color").get("B"), flash.get("end-alpha")), flash.get('ease'))
	
	#for pulse in Effects.beatpulse:
		#if pulse.get("time") != null and pulse.get("time") > Conductor.songPosition and pulse.get('time') < Conductor.songPosition + 1.0:
			#BeatPulse
