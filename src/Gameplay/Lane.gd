extends Control

var BaseNote = preload("res://src/Gameplay/note.tscn")

@export var ID = -1
@export var Hitpoint:float = Config.Hitpoint
@export var BackgroundAlpha:float = 0.4
@export var fake:bool = false

var Notes = []

@onready var Background:ColorRect = $Background
@onready var Receptor:Control = $Receptor

var Bind:Key = Key.KEY_SPACE

func _ready() -> void:
	if ID < 0 or typeof(ID) != TYPE_INT: push_error("ID is not valid")
	if Config.Binds[str(Utils.CurrentKeycount)].get(ID) != null:
		Receptor.get_node("Bind").text = var_to_str(Config.Binds[str(Utils.CurrentKeycount)].get(ID))
		Bind = Config.Binds[str(Utils.CurrentKeycount)].get(ID)
	else:
		Receptor.get_node("Bind").visible = false

func CreateNotes(notes):
	var id = -1
	for note in notes:
		id += 1
		var nobj = BaseNote.instantiate()
		nobj.name = str(id)
		nobj.type = note["type"]
		nobj.time = note["time"]
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
		if Bind == event.keycode and event.is_pressed():
			HitNote(event)
		if Bind == event.keycode and event.is_released():
			LetGo(event)

func HitNote(event:InputEventKey):
	Receptor.Press(true)
	var possible_notes = []
	var deferred_delete_notes = []
	for note in Notes:
		if note.visible:
			if note.canBeHit and note.mustPress and not note.tooLate and not note.wasGoodHit:
				var nostuffhappened = true
				for coolNote in possible_notes:
					if coolNote == note and abs(note.time - coolNote.time < 10):
						deferred_delete_notes.push_front(note)
						nostuffhappened = false
					elif coolNote == note and note.time < coolNote.time:
						pass
						#possible_notes.remove_at(possible_notes.find(coolNote))
						#possible_notes.push_front(note)
						#nostuffhappened = false
				
				if nostuffhappened:
					possible_notes.push_front(note)
	
	for note in deferred_delete_notes:
		if OS.is_debug_build(): Log.pr("Deleting note at "+note.time)
		Notes.remove_at(Notes.find(note))
		note.queue_free()
	
	possible_notes.sort_custom(func(a,b):
		if a.time < b.time:
			return true
		else: return false
		)
	
	if Utils.perfectMode:
		goodNoteHit(possible_notes[0])
	elif not possible_notes.is_empty():
		for coolnote in possible_notes:
			goodNoteHit(coolnote)
	else: noteMiss()

func noteMiss(): pass

func goodNoteHit(note):
	if not note.wasGoodHit:
		note.wasGoodHit = true
		Notes.remove_at(Notes.find(note))
		note.queue_free()
		if OS.is_debug_build(): Log.pr("note at "+str(note.time)+" hit successfully")

func LetGo(event:InputEventKey):
	Receptor.Press(false)

func _physics_process(_delta: float) -> void:
	for note in Notes:
		var calculatedtiming = (Hitpoint + (Conductor.songPosition - note.time) * (0.45 * Utils.round_to_dec(Config.ScrollSpeed, 2)))
		if calculatedtiming > 720 or calculatedtiming < -150:
			if note.visible: note.visible = false
		else:
			note.visible = true
			note.position.y = calculatedtiming

		if note.tooLate or note.wasGoodHit:
			Notes.remove_at(Notes.find(note))
			note.queue_free()
			if OS.is_debug_build(): Log.pr("note freed at "+str(note.time) + " the current time is "+str(Conductor.songPosition))
