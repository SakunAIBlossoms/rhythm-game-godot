extends TextureRect

signal Deleted()

@export_enum("Default", "Tick", "Hurt") var type:int = 0
@export var time:float = 0.0

func Setup():
	self.name = str(time)

var canHit = true

func Hit(success:bool):
	if canHit:
		canHit = false
		if !success:
			var twn = create_tween()
			twn.set_ease(Tween.EASE_OUT)
			twn.set_trans(Tween.TRANS_CIRC)
			twn.tween_property(self, "modulate", Color("95959580"), 0.4)
			twn.finished.connect(self.queue_free)
		else:
			self.visible = false
			if !self.is_queued_for_deletion():
				emit_signal("Deleted")
				self.queue_free()
