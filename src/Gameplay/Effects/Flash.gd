extends Control

func Flash(duration:float, first:Color, final:Color, easing:int) -> Tween:
	var newflash = $TemplateFlash.duplicate()
	var twn = create_tween()
	twn.set_ease(Utils.GetfluXisEasing(easing))
	twn.set_trans(Utils.GetfluXisTrans(easing))
	newflash.color = first
	twn.tween_property(newflash, "color", final, duration)
	twn.finished.connect(newflash.queue_free)
	newflash.visible = true
	self.add_child(newflash)
	
	return twn
