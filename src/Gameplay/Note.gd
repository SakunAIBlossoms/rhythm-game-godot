extends TextureRect

@export_enum("Default", "Tick", "Hurt") var type:int = 0
@export var time:float = 0.0

var mustPress:bool = true
var tooLate:bool = false
var willMiss:bool = false
var canBeHit:bool = true
var wasGoodHit:bool = false
var prevNote

func Setup():
	self.name = str(time)
	self.texture = Config.NoteSkin.HitObject.get(type)

var canHit = true
var HasBeenHit = false
var Missed = false

func Hit(success:bool):
	if canHit:
		canHit = false
		HasBeenHit = true
		if !success:
			var twn = create_tween()
			twn.set_ease(Tween.EASE_OUT)
			twn.set_trans(Tween.TRANS_CIRC)
			twn.tween_property(self, "modulate", Color("95959580"), 0.4)
		else:
			self.visible = false
			Missed = true


func _physics_process(_delta: float):
	if mustPress:
		if willMiss and not wasGoodHit:
			tooLate = true
			canBeHit = false
		else:
			if time > Conductor.songPosition - Conductor.safeZoneOffset:
				if time < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5):
					canBeHit = true
			else:
				canBeHit = true
				willMiss = true
	else:
		canBeHit = false

		if time <= Conductor.songPosition:
			wasGoodHit = true
	
	if tooLate: if self.modulate.a > 0.3: self.modulate.a = 0.3
