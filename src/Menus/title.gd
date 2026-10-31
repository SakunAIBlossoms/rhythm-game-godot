extends Control

func _ready():
	Overlay.get_node("Fade").color = Color.BLACK
	Utils.DoTweenProperty(Overlay.get_node("Fade"), "color", Color(0,0,0,0), 1.2, Tween.EASE_OUT, Tween.TRANS_CIRC)

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.is_action_pressed("ui_accept"):
			GoToMainMenu()

func GoToMainMenu():
	get_tree().change_scene_to_file("res://src/Menus/SongSelect.tscn")
