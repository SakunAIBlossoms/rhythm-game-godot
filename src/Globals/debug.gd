extends CanvasLayer
@warning_ignore_start("integer_division")


var FPSVisible = true

func _ready():
	ImGui.imgui_layout.connect(_show_debug)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_released() and event.keycode == Key.KEY_F3:
			FPSVisible = not FPSVisible


func _show_debug():
	if FPSVisible:
		var framerate = int(Engine.get_frames_per_second())
		var framerate_color = "Gold" if framerate > 30 else "Red"
		ImGui.set_next_window_size(250, 100, ImGuiApi.COND_ONCE)
		if ImGui.begin("Performance"):
			ImGui.text_colored(framerate_color,"FPS - "+str(framerate))
			if framerate < 10:
				ImGui.text("Concerning framerate detected!\nPlease check the render graph!")
			ImGui.text("Memory Usage - "+str(OS.get_static_memory_usage()/1000000)+"mb / "+str(OS.get_static_memory_peak_usage()/1000000)+"mb")
			if ImGui.button("Hide Performance", 0.0, 0.0):
				FPSVisible = false
		ImGui.end()
