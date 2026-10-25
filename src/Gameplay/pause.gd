extends CanvasLayer

signal Unpause()




func _on_resume_pressed() -> void:
	emit_signal("Unpause")
	self.visible = false
