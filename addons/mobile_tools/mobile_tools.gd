@tool
extends EditorPlugin

# ============================================================================
# VARIABLES
# ============================================================================

var status_label: Label
var panel: PanelContainer
var open_dialog_button: Button
var popup: AcceptDialog
var tree: Tree
var action_buttons: Array[CheckBox] = []
var page_nodes: VBoxContainer
var page_actions: VBoxContainer
var next_button: Button
var back_button: Button
var apply_button: Button
var cancel_button: Button
var editable_btn: CheckBox
var disable_editable_btn: CheckBox
var duplicate_btn: CheckBox
var show_btn: CheckBox
var hide_btn: CheckBox
var reset_transform_btn: CheckBox
var is_pro: bool = false

# ============================================================================
# NOTIFICATION
# ============================================================================

func _show_notification(title: String, message: String):
	var dialog = AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = message
	dialog.size = Vector2i(400, 150)
	get_editor_interface().get_base_control().add_child(dialog)
	dialog.popup_centered()
	dialog.connect("confirmed", Callable(dialog, "queue_free"))

# ============================================================================
# PLUGIN
# ============================================================================

func _enter_tree():
	_build_ui()
	add_control_to_bottom_panel(panel, "Raykit Tools")

func _exit_tree():
	remove_control_from_bottom_panel(panel)
	if popup:
		popup.queue_free()
	panel.queue_free()

# ============================================================================
# UI
# ============================================================================

func _build_ui():
	panel = PanelContainer.new()
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	open_dialog_button = Button.new()
	open_dialog_button.text = "Select Nodes"
	open_dialog_button.pressed.connect(_show_dialog)
	vbox.add_child(open_dialog_button)
	
	_build_dialog()

func _build_dialog():
	popup = AcceptDialog.new()
	popup.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	popup.get_ok_button().hide()
	get_editor_interface().get_base_control().add_child(popup)
	popup.hide()
	popup.title = "Raykit Tools"
	popup.size = Vector2i(700, 550)
	popup.unresizable = false
	
	var root = VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup.add_child(root)
	
	page_nodes = VBoxContainer.new()
	page_nodes.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(page_nodes)
	
	tree = Tree.new()
	tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tree.hide_root = true
	tree.columns = 1
	page_nodes.add_child(tree)
	tree.item_edited.connect(_on_tree_item_edited)
	
	var toolbar = HBoxContainer.new()
	toolbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_nodes.add_child(toolbar)

	var search_box = LineEdit.new()
	search_box.placeholder_text = "Search node..."
	search_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search_box.text_changed.connect(_search_node)
	toolbar.add_child(search_box)
	
	var select_all_btn = Button.new()
	select_all_btn.text = "Select All"
	select_all_btn.pressed.connect(_select_all)
	toolbar.add_child(select_all_btn)
	
	var deselect_all_btn = Button.new()
	deselect_all_btn.text = "Deselect All"
	deselect_all_btn.pressed.connect(_clear_all)
	toolbar.add_child(deselect_all_btn)
	
	page_actions = VBoxContainer.new()
	page_actions.visible = false
	root.add_child(page_actions)
	
	var title = Label.new()
	title.text = "Select an Action"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page_actions.add_child(title)
	
	duplicate_btn = CheckBox.new()
	duplicate_btn.text = "Duplicate Node"
	page_actions.add_child(duplicate_btn)
	
	editable_btn = CheckBox.new()
	editable_btn.text = "Enable Editable Children"
	page_actions.add_child(editable_btn)
	
	disable_editable_btn = CheckBox.new()
	disable_editable_btn.text = "Disable Editable Children"
	page_actions.add_child(disable_editable_btn)
	
	show_btn = CheckBox.new()
	show_btn.text = "Show Node"
	page_actions.add_child(show_btn)
	
	hide_btn = CheckBox.new()
	hide_btn.text = "Hide Node"
	page_actions.add_child(hide_btn)
	
	reset_transform_btn = CheckBox.new()
	reset_transform_btn.text = "Reset Transform"
	page_actions.add_child(reset_transform_btn)
	
	action_buttons = [
		editable_btn,
		disable_editable_btn,
		show_btn,
		hide_btn,
		reset_transform_btn,
		duplicate_btn,
	]
	for btn in action_buttons:
		btn.toggled.connect(_free_action_changed.bind(btn))
	
	status_label = Label.new()
	status_label.visible = false
	status_label.modulate = Color(1, 0.55, 0.4)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(status_label)
	
	var footer = HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	root.add_child(footer)
	
	back_button = Button.new()
	back_button.text = "Back"
	back_button.disabled = true
	back_button.pressed.connect(_back)
	footer.add_child(back_button)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(spacer)
	
	cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(_cancel)
	footer.add_child(cancel_button)
	
	next_button = Button.new()
	next_button.text = "Next"
	next_button.pressed.connect(_next)
	footer.add_child(next_button)
	
	apply_button = Button.new()
	apply_button.text = "Apply"
	apply_button.visible = false
	apply_button.pressed.connect(_apply)
	footer.add_child(apply_button)
	
	var btn_style = StyleBoxFlat.new()
	var btn_style_hover = btn_style.duplicate()
	var btn_style_pressed = btn_style.duplicate()
	
	btn_style_hover.bg_color = Color(0.32, 0.32, 0.36, 0.9)
	btn_style_pressed.bg_color = Color(0.18, 0.18, 0.2, 0.9)
	btn_style.bg_color = Color(0.25, 0.25, 0.28, 0.85)
	
	btn_style.corner_radius_top_left = 6
	btn_style.corner_radius_top_right = 6
	btn_style.corner_radius_bottom_left = 6
	btn_style.corner_radius_bottom_right = 6
	
	btn_style.content_margin_left = 18
	btn_style.content_margin_right = 18
	btn_style.content_margin_top = 10
	btn_style.content_margin_bottom = 10
	
	for btn in [next_button, back_button, apply_button, cancel_button]:
		btn.add_theme_font_size_override("font_size", 20)
		btn.custom_minimum_size = Vector2(0, 50)
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_stylebox_override("hover", btn_style_hover)
		btn.add_theme_stylebox_override("pressed", btn_style_pressed)

func _next():
	page_nodes.visible = false
	page_actions.visible = true
	back_button.disabled = false
	next_button.visible = false
	apply_button.visible = true

func _back():
	page_nodes.visible = true
	page_actions.visible = false
	back_button.disabled = true
	next_button.visible = true
	apply_button.visible = false

func _cancel():
	popup.hide()

func _free_action_changed(pressed: bool, current: CheckBox):
	if is_pro:
		return
	if not pressed:
		return
	for btn in action_buttons:
		if btn != current:
			btn.button_pressed = false

# ============================================================================
# HELPER
# ============================================================================

func _set_checked_children(item: TreeItem, checked: bool):
	if item == null:
		return
	var child = item.get_first_child()
	while child:
		child.set_checked(0, checked)
		_set_checked_children(child, checked)
		child = child.get_next()

func _iterate_items(item: TreeItem, callback: Callable):
	if item == null:
		return
	callback.call(item)
	var child = item.get_first_child()
	while child:
		_iterate_items(child, callback)
		child = child.get_next()

func _clear_all():
	var root := tree.get_root()
	if root == null:
		return
	_iterate_items(root, func(i): i.set_checked(0, false))

func _select_all():
	var root:TreeItem = tree.get_root()
	if root == null:
		return
	_iterate_items(root, func(i): i.set_checked(0, true))

func _search_node(text: String):
	text = text.to_lower()
	var root = tree.get_root()
	if root == null:
		return
	_filter_tree(root, text)

func _filter_tree(item: TreeItem, text: String):
	var is_visible = text == "" or item.get_text(0).to_lower().contains(text)
	item.visible = is_visible
	var child = item.get_first_child()
	while child:
		_filter_tree(child, text)
		if child.visible:
			item.visible = true
			item.collapsed = false
		child = child.get_next()

# ============================================================================
# DIALOG
# ============================================================================

func _show_dialog():
	page_nodes.visible = true
	page_actions.visible = false
	back_button.disabled = true
	next_button.visible = true
	apply_button.visible = false
	for btn in action_buttons:
		btn.button_pressed = false
	_refresh_tree()
	popup.popup_centered()

func _apply():
	var nodes = []
	_collect_checked(tree.get_root(), nodes)

	var any_duplicate = duplicate_btn.button_pressed
	if any_duplicate:
		var scene_root = get_editor_interface().get_edited_scene_root()
		nodes = nodes.filter(func(n): return n != scene_root)

	if nodes.is_empty():
		_show_notification("Error", "Select at least one node first.")
		return

	var action_map = [
		[editable_btn, func(n): return _enable_editable(n)],
		[disable_editable_btn, func(n): return _disable_editable(n)],
		[duplicate_btn, func(n): return _duplicate_nodes(n)],
		[show_btn, func(n): return _show_nodes(n)],
		[hide_btn, func(n): return _hide_nodes(n)],
		[reset_transform_btn, func(n): return _reset_transform(n)],
	]

	var checked_actions = action_map.filter(func(pair): return pair[0].button_pressed)

	if checked_actions.is_empty():
		_show_notification("Error", "Select an action first.")
		return

	if not is_pro and checked_actions.size() > 1:
		_show_notification("Locked", "Multi-action combo is a PRO feature.")
		return

	var scene_root = get_editor_interface().get_edited_scene_root()
	var applied := 0
	for pair in checked_actions:
		var target_nodes = nodes
		if pair[0] == duplicate_btn:
			target_nodes = _filter_top_level(nodes).filter(func(n): return n != scene_root)
		var result = pair[1].call(target_nodes)
		applied += result if result != null else 0

	if applied > 0:
		_show_notification("Success", "Action applied successfully!")
	else:
		_show_notification("Info", "Nothing to apply (root node can't be duplicated/re-parented).")
	popup.hide()

func _show_status(text: String):
	status_label.text = text
	status_label.visible = true

func _collect_checked(item: TreeItem, out: Array):
	while item:
		if item.is_checked(0):
			var node = item.get_metadata(0)
			if node:
				out.append(node)
		var child = item.get_first_child()
		if child:
			_collect_checked(child, out)
		item = item.get_next()

func _is_ancestor_of(maybe_ancestor: Node, node: Node) -> bool:
	var p := node.get_parent()
	while p:
		if p == maybe_ancestor:
			return true
		p = p.get_parent()
	return false

func _filter_top_level(nodes: Array) -> Array:
	var result := []
	for n in nodes:
		var is_descendant := false
		for other in nodes:
			if other != n and _is_ancestor_of(other, n):
				is_descendant = true
				break
		if not is_descendant:
			result.append(n)
	return result

# ============================================================================
# HELPER
# ============================================================================

func _refresh_tree():
	tree.clear()
	status_label.visible = false
	
	var scene = get_editor_interface().get_edited_scene_root()
	if scene == null:
		_show_notification("Error", "Open a scene first before selecting nodes.")
		return
		
	var root_item = tree.create_item()
	_add_node(root_item, scene, true)

func _add_node(parent: TreeItem, node: Node, is_root: bool = false):
	var item = tree.create_item(parent)
	item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	item.set_text(0, node.name)
	item.set_custom_color(0, Color.WHITE)
	item.set_custom_font_size(0, 20)
	item.set_checked(0, false)
	item.set_editable(0, true)
	item.set_metadata(0, node)
	item.collapsed = not is_root
	
	var icon = get_editor_interface().get_base_control().get_theme_icon(node.get_class(), "EditorIcons")
	if icon:
		item.set_icon(0, icon)
		
	if not is_root and node.scene_file_path != "":
		item.set_text(0, node.name + "  (Instance)")
		return
		
	for child in node.get_children():
		if child is Node:
			_add_node(item, child)

func _on_tree_item_edited():
	var item := tree.get_edited()
	if item == null:
		return
	_set_checked_children(item, item.is_checked(0))

# ============================================================================
# APPLY
# ============================================================================

func _enable_editable(nodes: Array) -> int:
	var undo := get_undo_redo()
	var count := 0

	undo.create_action("Enable Editable Children")

	for node in nodes:
		var parent:Node = node.get_parent()
		if parent and node.scene_file_path != "":
			undo.add_do_method(parent,"set_editable_instance",node,true)
			undo.add_undo_method(parent,"set_editable_instance",node,false)
			count += 1

	undo.commit_action()
	return count

func _disable_editable(nodes: Array) -> int:
	var undo := get_undo_redo()
	var count := 0

	undo.create_action("Disable Editable Children")

	for node in nodes:
		var parent:Node = node.get_parent()
		if parent and node.scene_file_path != "":
			undo.add_do_method(parent,"set_editable_instance",node,false)
			undo.add_undo_method(parent,"set_editable_instance",node,true)
			count += 1

	undo.commit_action()
	return count

func _duplicate_nodes(nodes: Array) -> int:
	var undo := get_undo_redo()
	var scene_root := get_editor_interface().get_edited_scene_root()
	var count := 0
	
	undo.create_action("Duplicate Nodes")
	
	for node in nodes:
		var parent: Node = node.get_parent()
		if parent == null:
			continue
			
		var dup:Node = node.duplicate(
			Node.DUPLICATE_SIGNALS |
			Node.DUPLICATE_GROUPS |
			Node.DUPLICATE_SCRIPTS
		)
		if dup is Node2D:
			dup.position += Vector2(20,20)
		elif dup is Node3D:
			dup.position += Vector3(0.25,0,0.25)
			
		undo.add_do_method(parent,"add_child",dup)
		undo.add_do_method(self,"_set_owner_recursive",dup,scene_root)
		undo.add_undo_method(parent,"remove_child",dup)
		count += 1
		
	undo.commit_action()
	return count

func _set_owner_recursive(node: Node, owner: Node):
	node.owner = owner
	for child in node.get_children():
		_set_owner_recursive(child, owner)

func _show_nodes(nodes: Array) -> int:
	var undo := get_undo_redo()
	var count := 0

	undo.create_action("Show Nodes")

	for node in nodes:
		if node is CanvasItem or node is Node3D:
			undo.add_do_property(node,"visible",true)
			undo.add_undo_property(node,"visible",false)
			count += 1

	undo.commit_action()
	return count

func _hide_nodes(nodes: Array) -> int:
	var undo := get_undo_redo()
	var count := 0

	undo.create_action("Hide Nodes")

	for node in nodes:
		if node is CanvasItem or node is Node3D:
			undo.add_do_property(node,"visible",false)
			undo.add_undo_property(node,"visible",true)
			count += 1

	undo.commit_action()
	return count

func _reset_transform(nodes: Array) -> int:
	var undo := get_undo_redo()
	var count := 0
	
	undo.create_action("Reset Transform")
	
	for node in nodes:
		if node is Node2D:
			undo.add_do_property(node, "position", Vector2.ZERO)
			undo.add_do_property(node, "rotation", 0.0)
			undo.add_do_property(node, "scale", Vector2.ONE)
			undo.add_undo_property(node, "position", node.position)
			undo.add_undo_property(node, "rotation", node.rotation)
			undo.add_undo_property(node, "scale", node.scale)
			count += 1
		elif node is Node3D:
			undo.add_do_property(node, "position", Vector3.ZERO)
			undo.add_do_property(node, "rotation", Vector3.ZERO)
			undo.add_do_property(node, "scale", Vector3.ONE)
			undo.add_undo_property(node, "position", node.position)
			undo.add_undo_property(node, "rotation", node.rotation)
			undo.add_undo_property(node, "scale", node.scale)
			count += 1
			
	undo.commit_action()
	return count
