extends Node

static var EffectHandler
var lastBeat = -1

static func Setup(handler):
	EffectHandler = handler

func _physics_process(_delta:float):
	if EffectHandler != null:
		if Conductor.curBeat > lastBeat:
			lastBeat = Conductor.curBeat
			#EffectHandler.Gameplay.Camera.zoom += Vector2(0.05,0.05)
