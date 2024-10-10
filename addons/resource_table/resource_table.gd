@tool
extends Control

@onready var tree = get_node("Tree")
var resources: Array[Resource] = []
const RESOURCE_PATH = "res://database/"

var dragging_column = -1
var drag_start_x = 0
var mouse_on_column_border = false

func _ready():
	tree.set_anchor(SIDE_RIGHT, 1)
	tree.set_anchor(SIDE_BOTTOM, 1)
	tree.set_offset(SIDE_LEFT, 0)
	tree.set_offset(SIDE_TOP, 0)
	tree.set_offset(SIDE_RIGHT, 0)
	tree.set_offset(SIDE_BOTTOM, 0)
	tree = $Tree
	tree.set_column_titles_visible(true)
	tree.set_columns(3)
	tree.set_column_title(0, "Nom")
	tree.set_column_title(1, "Type")
	tree.set_column_title(2, "Valeur")
	tree.connect("item_edited", Callable(self, "_on_Tree_item_edited"))
	
	#var refresh_button = Button.new()
	#refresh_button.text = "Rafraîchir"
	#refresh_button.connect("pressed", Callable(self, "load_and_update"))
	#add_child(refresh_button)
	
	tree.connect("resized", Callable(self, "_on_Tree_resized"))
	tree.connect("mouse_exited", Callable(self, "_on_Tree_mouse_exited"))
	
	load_and_update()
	
	set_process_input(true)

func load_and_update():
	load_resources()
	update_table()

func load_resources():
	resources.clear()
	var dir = DirAccess.open(RESOURCE_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var res = load(RESOURCE_PATH + file_name)
				if res:
					resources.append(res)
			file_name = dir.get_next()
	push_warning("Nombre de ressources chargées : " + str(resources.size()))

func update_table():
	tree.clear()
	var root = tree.create_item()
	tree.set_column_titles_visible(true)
	
	var columns = []
	if resources.size() > 0:
		for prop in resources[0].get_property_list():
			if prop.usage & PROPERTY_USAGE_EDITOR:
				columns.append(prop.name)
	
	tree.set_columns(columns.size() + 1)
	tree.set_column_title(0, "Fichier")
	for i in range(columns.size()):
		tree.set_column_title(i + 1, columns[i])
	
	for res in resources:
		var res_item = tree.create_item(root)
		res_item.set_text(0, res.resource_path.get_file())
		
		for i in range(columns.size()):
			var prop_name = columns[i]
			var value = res.get(prop_name)
			if value is Texture2D:
				res_item.set_cell_mode(i + 1, TreeItem.CELL_MODE_ICON)
				res_item.set_icon(i + 1, value)
				res_item.set_icon_max_width(i + 1, 32)
			else:
				res_item.set_text(i + 1, str(value))
			res_item.set_editable(i + 1, true)
			res_item.set_metadata(i + 1, {"resource": res, "property": prop_name})
	
	_on_Tree_resized()
	push_warning("Tableau mis à jour avec " + str(resources.size()) + " ressources")

func _on_Tree_item_edited():
	var edited_item = tree.get_edited()
	var column = tree.get_edited_column()
	var metadata = edited_item.get_metadata(column)
	if metadata:
		var res = metadata["resource"]
		var prop_name = metadata["property"]
		var current_value = res.get(prop_name)
		
		if current_value is Texture2D:
			var file_dialog = FileDialog.new()
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			file_dialog.access = FileDialog.ACCESS_RESOURCES
			file_dialog.filters = ["*.png ; PNG Images", "*.jpg ; JPEG Images"]
			file_dialog.connect("file_selected", Callable(self, "_on_image_selected").bind(res, prop_name))
			add_child(file_dialog)
			file_dialog.popup_centered(Vector2(800, 600))
		else:
			var new_text = edited_item.get_text(column)
			var prop_type = typeof(current_value)
			var new_value = convert_value(new_text, prop_type)
			
			res.set(prop_name, new_value)
			ResourceSaver.save(res, res.resource_path)
			push_warning("Ressource mise à jour : " + res.resource_path)

func _on_image_selected(path, res, prop_name):
	var new_texture = load(path)
	if new_texture:
		res.set(prop_name, new_texture)
		ResourceSaver.save(res, res.resource_path)
		push_warning("Image mise à jour : " + res.resource_path)
		load_and_update()

func convert_value(text, type):
	match type:
		TYPE_BOOL:
			return text.to_lower() == "true"
		TYPE_INT:
			return int(text)
		TYPE_FLOAT:
			return float(text)
		TYPE_STRING:
			return text
		_:
			return str_to_var(text)

func _input(event):
	if not is_visible_in_tree():
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var local_pos = tree.get_local_mouse_position()
				dragging_column = _get_column_at_position(local_pos.x)
				if dragging_column != -1:
					drag_start_x = local_pos.x
			else:
				dragging_column = -1
	elif event is InputEventMouseMotion:
		var local_pos = tree.get_local_mouse_position()
		if dragging_column != -1:
			var drag_distance = local_pos.x - drag_start_x
			var new_width = max(tree.get_column_width(dragging_column) + drag_distance, 50)
			tree.set_column_custom_minimum_width(dragging_column, new_width)
			drag_start_x = local_pos.x
		else:
			var column = _get_column_at_position(local_pos.x)
			if column != -1:
				if not mouse_on_column_border:
					mouse_on_column_border = true
					set_default_cursor_shape(CURSOR_HSIZE)
			else:
				if mouse_on_column_border:
					mouse_on_column_border = false
					set_default_cursor_shape(CURSOR_ARROW)

func _get_column_at_position(x_pos):
	var total_width = 0
	for i in range(tree.get_columns()):
		total_width += tree.get_column_width(i)
		if abs(total_width - x_pos) < 3:  # Réduit la zone de détection à 3 pixels
			return i
	return -1

func _on_Tree_resized():
	var total_width = tree.size.x
	var column_count = tree.get_columns()
	if column_count > 0:
		var default_width = total_width / column_count
		for i in range(column_count):
			tree.set_column_custom_minimum_width(i, default_width)

func _on_Tree_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	mouse_on_column_border = false
