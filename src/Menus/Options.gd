extends Control

var CategoryNode = preload("uid://dvtg45p43ejlq")
var CategoryTitleNode = preload("uid://dhb4mw5vfifol")

@onready var Music = get_node("BackgroundMusic")

const cog_spin_speed:float = 2.0

# Using a dictionary for this internally, not working with a team so I don't need to make it easily readable.
const defaultOptions = {
	"Volume" = {
		"Muted" = {
			"Type" = "Checkbox",
			"Default Value" = false,
			"Save Variable" = "VolumeCompletelyMuted"
		},
		"Master Volume" = {
			"Type" = "Slider",
			"Default Value" = 0.0,
			"Min" = -60.0,
			"Max" = 0.0,
			"Save Variable" = "MasterVolume"
		},
		"Music Volume" = {
			"Type" = "Slider",
			"Default Value" = 0.0,
			"Min" = -60.0,
			"Max" = 0.0,
			"Save Variable" = "MusicVolume"
		},
		"Hitsound Volume" = {
			"Type" = "Slider",
			"Default Value" = 0.0,
			"Min" = -60.0,
			"Max" = 0.0,
			"Save Variable" = "HitsoundVolume"
		},
	},
	"Display" = {
		"Fullscreen" = {
			"Type" = "Checkbox",
			"Default Value" = false,
			"Save Variable" = "FullscreenDisplayMode"
		},
		"Resolution" = {
			"Type" = "Dropdown",
			"Values" = ["1280x720", "1366x768", "1600x900", "1920x1080", "1048x1152", "2560x1440", "3200x1800", "3840x2160"],
			"Default Value" = 0,
			"Save Variable" = "DisplayResolutionOption"
		},
		"Shaders" = {
			"Type" = "Checkbox",
			"Default Value" = true,
			"Save Variable" = "GraphicsShadersEnabled"
		},
		"Antialiasing" = {
			"Type" = "Checkbox",
			"Default Value" = true,
			"Save Variable" = "AntialiasingEnabled"
		}
	},
	"Gameplay" = {
		"Scroll Speed" = {
			"Type" = "Number",
			"Default Value" = 2.4,
			"Save Variable" = "ScrollSpeed"
		},
		"Visual Effects" = {
			"Type" = "Checkbox",
			"Default Value" = true,
			"Save Variable" = "VisualEffectsEnabled"
		}
	}
}

@onready var CategoryList = $Categories/Scroll/List
@onready var OptionList = $IndividualOptions/Scroll/List

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Utils.emit_signal("SetVolumeState", false);
	if Config.GetOption("GraphicsShadersEnabled") == false: $Background.queue_free()

	# Option loading and setup
	for category in defaultOptions:
		#Log.pr(category)
		var newcategory = CategoryNode.instantiate()
		newcategory.Setup(category, "res://Assets/Icons/"+category+".svg")
		newcategory.name = category
		CategoryList.add_child(newcategory)
		newcategory.get_node("Button").pressed.connect(func(): show_category(category))

		var title = CategoryTitleNode.instantiate()
		title.get_node("Title").text = category
		title.add_to_group(category)
		OptionList.add_child(title)

		var categorylist:Dictionary = defaultOptions[category]
		for option in categorylist:
			var data = categorylist.get(option)
			var newoptionnode = get_option_type(data.get("Type"))
			if newoptionnode == null: return
			# Change Title
			newoptionnode.get_node("Title").text = option

			var value = newoptionnode.get_node("Value")
			var defaultvalue = Config.GetOption(data.get("Save Variable")) if Config.GetOption(data.get("Save Variable")) != null else data.get("Default Value")
			# Setup callbacks
			if (value is Slider):
				value.max_value = data.get("Max")
				value.min_value = data.get("Min")
				value.set_value_no_signal(defaultvalue)
				
				# Finish config before letting this be configured.
				value.value_changed.connect(func(v:float): Config.UpdateOption(data.get("Save Variable"), v))
						
			if (value is CheckButton):
				value.button_pressed = defaultvalue
				value.toggled.connect(func(state:bool): Config.UpdateOption(data.get("Save Variable"), state))
			
			if (value is SpinBox):
				value.set_value_no_signal(defaultvalue)
				value.value_changed.connect(func(newvalue:float): Config.UpdateOption(data.get("Save Variable"), newvalue))
			
			if (value is OptionButton):
				newoptionnode.Setup(data.get("Values"))
				value.select(defaultvalue)
				value.item_selected.connect(func(index:int): Config.UpdateOption(data.get("Save Variable"), index))
			
			newoptionnode.add_to_group(category)
			OptionList.add_child(newoptionnode)
	
	# Music connections
	Music.Beat.connect(func(b:int):
		if b % 4 == 0:
			$Topbar/Cog.scale += Vector2(0.3,0.3)
		else:
			$Topbar/Cog.scale += Vector2(0.2, 0.2)
		)
	Music.Step.connect(func(_s:int):
		$Topbar/Cog.scale += Vector2(0.1, 0.1)
		)

	var twn = create_tween()
	twn.tween_property(Overlay.get_node("Fade"), "color", Color(0,0,0,0), 0.8).from(Color.BLACK)

func get_option_type(type:String):
	match(type):
		"Slider": return load("res://src/Menus/Options/Slider.tscn").instantiate()
		"Checkbox": return load("res://src/Menus/Options/Checkbox.tscn").instantiate()
		"Number": return load("res://src/Menus/Options/NumberBox.tscn").instantiate()
		"Dropdown": return load("res://src/Menus/Options/Dropdown.tscn").instantiate()
		_: return null

func _process(delta: float) -> void:
	$Topbar/Cog.scale = Vector2(lerpf($Topbar/Cog.scale.x, 1.0, 6.0*delta), lerpf($Topbar/Cog.scale.y, 1.0, 6.0*delta))
	$Topbar/Title.rotation = sin(deg_to_rad(Time.get_ticks_msec() * 0.16)) * 0.03
	$Topbar/Cog.rotation_degrees += 2 * cog_spin_speed

func show_category(category:String):
	for node in OptionList.get_children():
		if node.is_in_group(category):
			node.visible = true
		else:
			node.visible = false

func show_all_categories():
	for node in OptionList.get_children():
		node.visible = true

func _return_to_menu():
	var fade = Overlay.get_node("Fade")
	var twn = create_tween().set_parallel(true)
	twn.set_ease(Tween.EASE_IN)
	twn.set_trans(Tween.TRANS_CIRC)
	twn.tween_property(fade, "color", Color(0,0,0,1), 1.2).finished.connect(func(): Config.Save(); Utils.emit_signal("SetVolumeState", true); get_tree().change_scene_to_file("uid://b8rvgonqqu8re"))
	twn.tween_property($BackgroundMusic, "volume_db", -60.0, 0.8)
	var newtwn = create_tween().set_parallel(true)
	newtwn.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	newtwn.tween_property($Topbar, "position:y", -188, 1.0)
	newtwn.tween_property($Categories, "position:y", 800, 1.0)
	newtwn.tween_property($IndividualOptions, "position:y", 800, 1.0).set_delay(.2)
