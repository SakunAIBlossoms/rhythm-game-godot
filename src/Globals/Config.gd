extends Node

var Options = {}

var ScrollSpeed = 2.4
var Upscroll = true
var CurrentResolution = Utils.resolutions[0]
var Binds = {
	"0" = [],
	"1" = [Key.KEY_SPACE],
	"2" = [Key.KEY_F, Key.KEY_J],
	"3" = [Key.KEY_F, Key.KEY_SPACE, Key.KEY_J],
	"4" = [Key.KEY_D, Key.KEY_F, Key.KEY_J, Key.KEY_K],
	"5" = [Key.KEY_D, Key.KEY_F, Key.KEY_SPACE, Key.KEY_J, Key.KEY_K],
	"6" = [Key.KEY_S, Key.KEY_D, Key.KEY_F, Key.KEY_J, Key.KEY_K, Key.KEY_L]
}
var Hitpoint = 580
var NoteSkin = {
	HitObject = [
		preload("res://Assets/Skins/Default/HitObjects/Note/1.png"),
		preload("res://Assets/Skins/Default/HitObjects/Tick/Tick.png"),
		preload("res://Assets/Skins/Default/HitObjects/Landmine/Landmine.png")
	]
}

var Antialiasing: Viewport.MSAA:
	set(value): Antialiasing = value; get_viewport().msaa_2d = value;
	get: return Antialiasing

func _ready():
	if (FileAccess.file_exists("user://SettingsData.json")):
		var file = FileAccess.open("user://SettingsData.json", FileAccess.READ)
		var rawtxt = file.get_as_text()
		var json = JSON.parse_string(rawtxt)
		if json != null: Options = json
	else:
		Options = {}

func UpdateOption(Option:String, value:Variant) -> bool:
	var success = Options.set(Option, value)
	
	ForceUpdateSettings(Option)
	
	return success

func GetOption(Option:String) -> Variant:
	return Options.get(Option, null)

func ForceUpdateSettings(Option:String):
	match(Option):
		"AntialiasingMode": get_viewport().msaa_2d = Options.get(Option, Viewport.MSAA_DISABLED)
		"VolumeCompletelyMuted": AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), Options.get(Option, false))
		"MasterVolume": Volume.volume = Options.get(Option, 0.0)
		"MusicVolume": AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), Options.get(Option, 0.0))
		"HitsoundVolume": AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Hitsounds"), Options.get(Option, 0.0))
		"FullscreenDisplayMode": get_window().mode = Window.MODE_FULLSCREEN if Options.get(Option, false) else Window.MODE_WINDOWED
		"DisplayResolutionOption": get_window().size = Utils.resolutions.get(Options.get(Option, 0))
		_: Log.pr("No value for forcing a value update.")

func Save():
	var OptionsFile = FileAccess.open("user://SettingsData.json", FileAccess.WRITE)
	var tostring = JSON.stringify(Options)
	OptionsFile.store_string(tostring)
	OptionsFile.close()
