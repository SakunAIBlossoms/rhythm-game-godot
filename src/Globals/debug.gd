extends CanvasLayer

var FPSVisible = true

func _ready():
	ImGui.imgui_layout.connect(_show_debug)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_released() and event.keycode == Key.KEY_F3:
			FPSVisible = not FPSVisible


func _show_debug():
	if FPSVisible:
		if ImGui.begin_ex("Performance", ImGuiApi.WINDOW_NO_RESIZE):
			ImGui.text_colored("Gold","FPS - "+str(int(Engine.get_frames_per_second())))
			if ImGui.button("Hide Performance", 0.0, 0.0):
				FPSVisible = false
		ImGui.end()
