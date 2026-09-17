extends Control


func Press(State:bool):
	if State:
		$Down.visible = true
		$Up.visible = false
	else:
		$Down.visible = false
		$Up.visible = true
