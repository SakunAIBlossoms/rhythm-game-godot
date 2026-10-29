extends Control

var state = false

func Press(State:bool):
	state = State
	if State:
		$Down.visible = true
		$Up.visible = false
	else:
		$Down.visible = false
		$Up.visible = true
