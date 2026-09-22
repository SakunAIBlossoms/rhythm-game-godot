extends RichTextLabel

var WaveSetup = "[wave amp=60.0 freq=2.0 connected=0]"
var ID:int = 0
var _data

func Setup(data):
	_data = data
	text = WaveSetup+data.get("Name")
	$Preview.stream = load("res://Songs/"+data.get("RawName")+"/"+data.get("AudioFile"))
	Log.pr(data.get("RawName")+" has loaded successfully")

func Selected():
	$Preview.play(_data.get("PreviewTime"))

func Unselected():
	$Preview.stop()
