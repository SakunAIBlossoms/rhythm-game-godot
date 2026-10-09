extends CanvasLayer

func Flash(duration:float, first:Color, final:Color, easing:int) -> Tween:
	var twn = create_tween()
	twn.set_ease(Utils.GetfluXisEasing(easing))
	twn.set_trans(Utils.GetfluXisTrans(easing))
	twn.tween_property($obj, "color", final, duration).from(first)
	twn.play()
	
	return twn
