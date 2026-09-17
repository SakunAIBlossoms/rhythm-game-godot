extends Control

var BaseNote = preload("res://src/Gameplay/note.tscn")

@export var song_position = 0.0

@export var ID = -1
@export var Hitpoint:float = 620
@export var BackgroundAlpha:float = 0.4
@export var speed = 100.0

@onready var Background:ColorRect = $Background
@onready var Receptor:Control = $Receptor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ID < 0 or typeof(ID) != TYPE_INT: push_error("ID is not valid")

func CreateNotes(notes):
	var id = -1
	for note in notes:
		id += 1
		var nobj = BaseNote.instantiate()
		nobj.name = str(id)
		nobj.type = notes[note]["type"]
		nobj.time = notes[note]["time"]
		#nobj.position.y = 
		$Notes.add_child(nobj)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Receptor.position.y != Hitpoint:
		Receptor.position.y = lerpf(Receptor.position.y, Hitpoint, 12*delta)
	if Background != null:
		if Background.color.a != BackgroundAlpha:
			Background.color.a = lerpf(Background.color.a, BackgroundAlpha, 12*delta)
	

func _physics_process(delta: float) -> void:
	for note in $Notes.get_children():
		note.position.y = note.time
		#print(note.position.y)
		#if note.position.y > self.size.y:
		#	note.queue_free()
