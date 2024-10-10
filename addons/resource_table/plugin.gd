@tool
extends EditorPlugin

var resource_table

func _enter_tree():
	resource_table = preload("res://addons/resource_table/resource_table.tscn").instantiate()
	resource_table.name = "Resources Database"
	get_editor_interface().get_editor_main_screen().add_child(resource_table)
	_make_visible(false)

func _exit_tree():
	if resource_table:
		resource_table.queue_free()

func _has_main_screen():
	return true

func _make_visible(visible):
	if resource_table:
		resource_table.visible = visible

func _get_plugin_name():
	return "Database"

func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Object", "EditorIcons")
