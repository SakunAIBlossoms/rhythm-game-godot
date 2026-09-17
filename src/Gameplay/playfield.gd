extends Control

@export var Keycount = 4
@export var song_position = 0.0
@export var upscroll:bool = false

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
			add_child(templane)
			templane.position.x = templane.size.x * key
		else:
			push_error("Cannot instantiate lane "+str(key))
	self.position.x = self.position.x - self.size.x / 2

func _physics_process(delta: float) -> void:
	for lane in get_children():
		lane.song_position = song_position
