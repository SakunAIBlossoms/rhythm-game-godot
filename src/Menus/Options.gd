extends Control

@onready var Music = get_node("BackgroundMusic")

const cog_spin_speed:float = 2.0

# Using a dictionary for this internally, not working with a team so I don't need to make it easily readable.
const defaultOptions = {
	"Volume" = {
		"Master Volume" = {
			"Type" = "Slider"
		}
	}
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Music.Beat.connect(func(b:int):
		if b % 4 == 0:
			$Topbar/Cog.scale += Vector2(0.3,0.3)
		else:
			$Topbar/Cog.scale += Vector2(0.2, 0.2)
		)
	Music.Step.connect(func(_s:int):
		$Topbar/Cog.scale += Vector2(0.1, 0.1)
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Topbar/Cog.scale = Vector2(lerpf($Topbar/Cog.scale.x, 1.0, 6.0*delta), lerpf($Topbar/Cog.scale.y, 1.0, 6.0*delta))
	$Topbar/Title.rotation = sin(deg_to_rad(Time.get_ticks_msec() * 0.16)) * 0.03
	$Topbar/Cog.rotation_degrees += 2 * cog_spin_speed
