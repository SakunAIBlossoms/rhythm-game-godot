extends CanvasLayer

var TemplateError = preload("res://src/TemplateErrorDebug.tscn")

func AddError(Content):
	var NewError = TemplateError.instantiate()
	NewError.Update(Content)
	$ErrorList.add_child(NewError)
