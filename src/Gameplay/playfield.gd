extends Control

@export var Keycount = 4

# Called when the node enters the scene tree for the first time.
func setup(data) -> void:
	var lane = preload("res://src/Gameplay/Lane.tscn")
	for key in Keycount:
		if lane.can_instantiate():
			var templane = lane.instantiate()
			templane.ID = key
			templane.CreateNotes(data)
		else:
			push_error("Cannot instantiate lane "+str(key))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
