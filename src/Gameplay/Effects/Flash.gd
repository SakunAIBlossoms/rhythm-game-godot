extends ColorRect

func Flash(duration:float, first:Color, final:Color, easing:int) -> Tween:
	var twn = create_tween()
	twn.set_ease(Utils.GetfluXisEasing(easing))
	twn.set_trans(Utils.GetfluXisTrans(easing))
	twn.tween_property(self, "color", final, duration).from(first)
	
	return twn
