extends Control

@export var Keycount = 4

# Called when the node enters the scene tree for the first time.
func setup(data) -> void:
	var sortednotes = {"1" = {}, "2" = {}, "3" = {}, "4" = {}}
	
	for note in data:
		sortednotes[data[note]["lane"]].set(note, data[note])
	
	var lane = preload("res://src/Gameplay/Lane.tscn")
	for key in Keycount:
		if lane.can_instantiate():
			var templane = lane.instantiate()
			templane.ID = key
			templane.CreateNotes(sortednotes[str(key+1)])
			templane.name = str(key)
			add_child(templane)
			templane.position.x = templane.size.x * key
		else:
			push_error("Cannot instantiate lane "+str(key))
	self.position.x = self.position.x - self.size.x / 2

func _physics_process(_delta: float) -> void:
	if Config.Upscroll:
		self.scale.y = -1
		self.position.y = 720
	else:
		self.scale.y = 1
		self.position.y = 0
