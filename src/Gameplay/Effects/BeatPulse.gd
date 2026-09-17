extends Node

static var EffectHandler
var lastBeat = -1

static func Setup(handler):
	EffectHandler = handler

func _physics_process(delta:float):
	if EffectHandler != null:
		if Conductor.curBeat > lastBeat:
			lastBeat = Conductor.curBeat
			EffectHandler.Gameplay.Camera
