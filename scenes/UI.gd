extends Node

var ui_manager = null


# Called when the node enters the scene tree for the first time.
func _ready():
	update_ui_manager()

func update_ui_manager():
	if is_instance_valid(get_viewport().get_node("ui_manager")):
		ui_manager = get_viewport().get_node("ui_manager")
	else:
		ui_manager = null

func get_ui_manager():
	if ui_manager != null:
		return ui_manager.self
	else:
		return null

func defer_ui_call(function):
	if ui_manager != null:
		ui_manager.call(function)
	else:
		return null
