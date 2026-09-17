extends Node

func GetBeatFromTime(beat, time):
	print(time * beat / 60)
	return time * beat / 60


func GetfluXisEasing(easing:int) -> Tween.EaseType:
	var e:Tween.EaseType
	match(easing):
		# None
		0, 5, 8, 11, 14, 17, 20, 23, 28, 31, 34: e = Tween.EaseType.EASE_IN_OUT
		1, 4, 7, 10, 13, 16, 19, 22, 25, 30, 33: e = Tween.EaseType.EASE_OUT
		2, 3, 6, 9, 12, 15, 18, 21, 24, 29, 32: e = Tween.EaseType.EASE_IN
		_:
			if easing > 35:
				Log.warn("Invalid Easing")
			else:
				Log.warn(easing, " is not an implemented easing.")
	
	return e

func GetfluXisTrans(trans:int) -> Tween.TransitionType:
	var t:Tween.TransitionType
	
	match(trans):
		0,1,2: t = Tween.TransitionType.TRANS_LINEAR
		3,4,5: t = Tween.TransitionType.TRANS_QUAD
		6,7,8: t = Tween.TransitionType.TRANS_CUBIC
		9,10,11: t = Tween.TransitionType.TRANS_QUART
		12,13,14: t = Tween.TransitionType.TRANS_QUINT
		15,16,17: t = Tween.TransitionType.TRANS_SINE
		18,19,20: t = Tween.TransitionType.TRANS_EXPO
		21,22,23: t = Tween.TransitionType.TRANS_CIRC
		24,25,28: t = Tween.TransitionType.TRANS_ELASTIC
		29,30,31: t = Tween.TransitionType.TRANS_BACK
		32,33,34: t = Tween.TransitionType.TRANS_BOUNCE
		_:
			if trans > 35:
				Log.warn("Invalid Transition")
			else:
				Log.warn(trans, " is not an implemented easing!")
	
	return t

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
