extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Overlay.get_node("Fade").color = Color.BLACK
	Utils.DoTweenProperty(Overlay.get_node("Fade"), "color", Color(0,0,0,0), 1.2, Tween.EASE_OUT, Tween.TRANS_CIRC)

func _process(_dt:float):
	$Logo.rotation = sin(deg_to_rad(Time.get_ticks_msec() * 0.16)) * 0.03

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.is_action_pressed("ui_accept"):
			GoToMainMenu()

func GoToMainMenu():
	get_tree().change_scene_to_file("res://src/Menus/SongSelect.tscn")
