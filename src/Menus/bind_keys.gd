extends Control

signal UpdatedKey(newkey:Key)
var waitingforkeyupdate = false

var curKeycount = 4

var LastKeyPress = Key.KEY_NONE

func _ready():
	var keycount = 0
	for child in $Playfields.get_children():
		keycount += 1
		for lane in child.get_children():
			var button:Button = lane.get_node("Button")
			button.pressed.connect(func():
				_update_bind_for_lane(int(lane.name))
				Log.pr("Updating bind for lane ", lane.name)
				)
			
			lane.get_node("CurrentKey").text = OS.get_keycode_string(Config.Binds.get(str(keycount)).get(int(lane.name)-1))
	
	$Options/Upscroll.set_pressed_no_signal(Config.GetOption("Upscroll") if typeof(Config.GetOption("Upscroll")) == TYPE_BOOL else false)
	$Options/Hitpoint.set_value_no_signal(720.0-(Config.GetOption("Hitpoint") if typeof(Config.GetOption("Hitpoint")) == TYPE_FLOAT else 580.0))

func _on_keycount_item_selected(index: int) -> void:
	curKeycount = index
	for child in $Playfields.get_children():
		if int(child.name) == index:
			child.visible = true
		else:
			child.visible = false

func _on_upscroll_toggled(toggled_on: bool) -> void:
	Config.UpdateOption("Upscroll", toggled_on)

func _unhandled_key_input(event: InputEvent):
	if event is InputEventKey:
		if waitingforkeyupdate:
			if event.keycode != Key.KEY_ESCAPE or event.keycode != Key.KEY_ENTER or event.keycode != Key.KEY_BACKSPACE:
				LastKeyPress = event.keycode
				emit_signal("UpdatedKey", LastKeyPress)

func _on_back_pressed() -> void:
	self.visible = false
	Config.Save()

func _update_bind_for_lane(key:int):
	waitingforkeyupdate = true
	$WaitingForKey.visible = true
	$WaitingForKey/Title.text = "Waiting for key press to bind lane "+str(key)
	await UpdatedKey
	$WaitingForKey.visible = false
	$Playfields.get_node(str(curKeycount)).get_node(str(key)).get_node("CurrentKey").text = OS.get_keycode_string(LastKeyPress)
	var binds:Array = Config.Binds.get(str(curKeycount))
	binds.set(key-1, LastKeyPress)
	waitingforkeyupdate = false

func _on_hitpoint_value_changed(value: float) -> void:
	Config.UpdateOption("Hitpoint", 720.0-value)
