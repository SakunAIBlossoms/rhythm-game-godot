extends Control

func _process(delta: float) -> void:
	var hitpoint = Config.GetOption("Hitpoint") if typeof(Config.GetOption("Hitpoint")) == TYPE_FLOAT else 580.0
	if $Receptor.position.y != hitpoint: $Receptor.position.y = lerp($Receptor.position.y, hitpoint, 12*delta)
