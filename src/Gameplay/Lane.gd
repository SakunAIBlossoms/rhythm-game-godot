extends Control

signal Hit(Rating:String, Delay:float)
signal Missed()

var BaseNote = preload("res://src/Gameplay/note.tscn")

@export var ID = -1
@export var Hitpoint:float = Config.Hitpoint
@export var BackgroundAlpha:float = 0.4
@export var fake:bool = false

var Notes = []
var unspawnedNotes = []

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
		nobj.Setup()
		unspawnedNotes.push_back(nobj)
		$Notes.add_child(nobj)
		nobj.visible = false
		nobj.position.y = (Hitpoint + (Conductor.songPosition - nobj.time) * (0.45 * Utils.round_to_dec(Config.ScrollSpeed, 2)))
	
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
	
	var note = closest(Conductor.songPosition, Notes)
	if note == null: return
	var delay = Conductor.songPosition - note.time
	Log.pr("Attempting to hit note with time difference of ", delay)
	if note.type == 0:
		if delay < 160 and delay > -160:
			note.Hit(true)
			HitWindowCalculations(delay)
			$Hitsound.play()
		elif delay > 160 and delay < 240:
			note.Hit(false)
			Log.pr("Hit failed because you were TOO LATE OR EARLY NOOB")
			HitWindowCalculations(delay)
			emit_signal("Missed")
			$Hitsound.play()
		elif delay < -160 and delay > -240:
			note.Hit(false)
			Log.pr("Hit failed because you were TOO LATE OR EARLY NOOB")
			HitWindowCalculations(delay)
			emit_signal("Missed")
			$Hitsound.play()
		else:
			Log.pr("No note hit")

func HitWindowCalculations(delay:float):
	# Perfect
	if delay < 45.0 and delay > -45.0:
		emit_signal("Hit", "Perfect", delay)
	elif delay < 90.0 and delay > -90.0:
		emit_signal("Hit", "Good", delay)
	elif delay < 135.0 and delay > -135.0:
		emit_signal("Hit", "Bad", delay)
	else:
		emit_signal("Hit", "Horrid", delay)

func closest(timestamp:float, n:Array):
	# Initialize
	var closest_num
	var closest_delta = 0
	var temp_delta = 0
	# Loop through entire array
	for i in range(n.size()):
		if n[i].time == timestamp: return n[i] # exact match found!
		temp_delta = float(abs(n[i].time-timestamp))
		if closest_delta == 0 or temp_delta < closest_delta:
			closest_num = n[i]
			closest_delta = temp_delta
	# Return closest number found
	return closest_num

func LetGo(event:InputEventKey):
	Receptor.Press(false)

func _physics_process(_delta: float) -> void:
	for note in unspawnedNotes:
		var calculatedtiming = (Hitpoint + (Conductor.songPosition - note.time) * (0.45 * Utils.round_to_dec(Config.ScrollSpeed, 2)))
		if calculatedtiming > 720 or calculatedtiming < -150:
			if note.visible: note.visible = false
		else:
			if Notes.find(note) == -1:
				unspawnedNotes.remove_at(unspawnedNotes.find(note))
				Notes.push_front(note)
				Log.pr("Pushed ", note, " to the front of the notes array")
	
	for note in Notes:
		if note.canHit:
			note.visible = true
			note.position.y = (Hitpoint + (Conductor.songPosition - note.time) * (0.45 * Utils.round_to_dec(Config.ScrollSpeed, 2)))
			if note.type == 1:
				if note.position.y >= Hitpoint and Receptor.state:
					note.Hit(true)
					$Hitsound.play()
		
		if note.HasBeenHit or note.Missed:
			note.visible = false
			note.canHit = false
			Notes.remove_at(Notes.find(note))
			if OS.is_debug_build(): Log.pr("note freed at "+str(note.time) + " the current time is "+str(Conductor.songPosition))
