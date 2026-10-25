extends SubViewport

@export var Keycount:int = 4

var lanes = []

# Called when the node enters the scene tree for the first time.
func setup(data:Array, fake) -> void:
	#data.sort_custom(
	#	)

	var sortednotes = {"1" = {}, "2" = {}, "3" = {}, "4" = {}, "5" = {}}
	
	for note in data:
		sortednotes[data[note]["lane"]].set(note, data[note])
	
	var lane = preload("res://src/Gameplay/Lane.tscn")
	for key in Keycount:
		if lane.can_instantiate():
			var templane = lane.instantiate()
			templane.ID = key
			templane.CreateNotes(sortednotes[str(key+1)])
			templane.name = str(key)
			templane.fake = fake
			add_child(templane)
			templane.position.x = templane.size.x * key
			self.size.x += templane.size.x
			lanes.push_front(templane)
		else:
			push_error("Cannot instantiate lane "+str(key))

func _physics_process(_delta: float) -> void:
	if Config.Upscroll:
		for lane in lanes:
			lane.scale.y = -1
			lane.position.y = 720
	else:
		for lane in lanes:
			self.scale.y = 1
			self.position.y = 0
