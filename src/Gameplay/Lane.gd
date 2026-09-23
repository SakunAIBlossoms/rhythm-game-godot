extends Control

var BaseNote = preload("res://src/Gameplay/note.tscn")

@export var ID = -1
@export var Hitpoint:float = Config.Hitpoint
@export var BackgroundAlpha:float = 0.4

var Notes = []

@onready var Background:ColorRect = $Background
@onready var Receptor:Control = $Receptor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ID < 0 or typeof(ID) != TYPE_INT: push_error("ID is not valid")
	if Config.Binds[ID] != null:
		Receptor.get_node("Bind").text = Config.Binds[ID].to_upper()
	else:
		Receptor.get_node("Bind").visible = false

func CreateNotes(notes):
	var id = -1
	for note in notes:
		id += 1
		var nobj = BaseNote.instantiate()
		nobj.name = str(id)
		nobj.type = notes[note]["type"]
		nobj.time = notes[note]["time"]
		Notes.push_back(nobj)
		$Notes.add_child(nobj)
	
	Notes.sort_custom(func(a, b):
		if a.time < b.time:
			return true
		return false
		)

func _process(delta: float) -> void:
	if Receptor.position.y != Hitpoint:
		Receptor.position.y = lerpf(Receptor.position.y, Hitpoint, 12*delta)
	if Background != null:
		if Background.color.a != BackgroundAlpha:
			Background.color.a = lerpf(Background.color.a, BackgroundAlpha, 12*delta)
	#if Config.Upscroll:
	#	Receptor.get_node("Timing").position.y = Receptor.get_node("Timing").position.y

func _unhandled_input(event: InputEvent):
	if event is InputEventKey:
		if Config.Binds[ID].to_upper() == event.as_text() and event.is_pressed():
			HitNote()
		if Config.Binds[ID].to_upper() == event.as_text() and event.is_released():
			LetGo()

func HitNote():
	Receptor.Press(true)

func LetGo():
	Receptor.Press(false)

func _physics_process(_delta: float) -> void:
	for note in Notes:
		note.position.y = (Hitpoint + (Conductor.songPosition - note.time) * (0.45 * Utils.round_to_dec(Config.ScrollSpeed, 2)))
		
		if note.position.y > self.size.y:
			note.visible = false
			note.Missed = true
