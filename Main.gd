# Lore Elements — Main autoload entry point.
# See PLANNING.md for project context, architecture, and phased roadmap.
extends Node

const NOTE_DATA_PATH := "res://rtv-lore-elements/data/notes.json"
const NOTE_ITEM_PATH_PREFIX := "res://rtv-lore-elements/Items/Lore/Notes/"
const READER_FONT_PATH := "res://rtv-lore-elements/assets/fonts/Caveat-Regular.ttf"
const NOTE_LOOT_TABLE := "LT_Master"
const LEGACY_HELLO_NOTE_ID := "rtv_lore_hello_note"
const LEGACY_HELLO_NOTE := {
	"id": LEGACY_HELLO_NOTE_ID,
	"name": "Damaged Field Note",
	"inventory": "Field Note",
	"rotated": "Field Note",
	"equipment": "F. Note",
	"display": "F. Note",
	"rarity": 0,
	"value": 25,
	"civilian": true,
	"industrial": true,
	"military": true,
	"pages": [
		"Day 11 after the border closed.\n\nThe checkpoint lights still blink at night, but no one answers the radio. We found boot tracks by the birch line and three spent casings in the snow.",
		"Someone came through here after the evacuation order.\n\nIf this reaches the cabin, tell Leena I kept the brass compass. It points north even when everything else lies."
	]
}

var NOTE_ITEM_TEMPLATE = preload("res://rtv-lore-elements/Items/Lore/Note_HelloWorld/Note_HelloWorld.tres")
var NOTE_SCENE_TEMPLATE = preload("res://rtv-lore-elements/Items/Lore/Note_HelloWorld/Note_HelloWorld.tscn")

var _lib = null
var _use_hook_id := -1
var _context_use_hook_id := -1
var _ui_manager_input_hook_id := -1

var _notes := {}
var _reader_font = null

var _reader: CanvasLayer = null
var _reader_interface_node: Node = null
var _reader_note_id := ""
var _reader_page_index := 0
var _reader_title: Label = null
var _reader_body: RichTextLabel = null
var _reader_page_counter: Label = null
var _reader_prev_button: Button = null
var _reader_next_button: Button = null

func _ready() -> void:
	if Engine.has_meta("RTVModLib"):
		var lib = Engine.get_meta("RTVModLib")
		if lib._is_ready:
			_on_lib_ready()
		else:
			lib.frameworks_ready.connect(_on_lib_ready)
	else:
		push_warning("[rtv_lore_elements] RTVModLib meta not present - Metro Mod Loader required.")

func _input(event: InputEvent) -> void:
	if _reader && is_instance_valid(_reader) && _is_reader_cancel_event(event):
		get_viewport().set_input_as_handled()
		_close_reader()

func _on_lib_ready() -> void:
	_lib = Engine.get_meta("RTVModLib")
	print("[rtv_lore_elements] frameworks ready, registering...")
	_load_reader_font()
	if _reader_font == null:
		push_warning("[rtv_lore_elements] Caveat font unavailable; reader will use the default UI font.")
	_register_read_hooks()
	_register_ui_manager_input_hook()
	_register_lore_content()

func _load_reader_font() -> void:
	var font := FontFile.new()
	var error := font.load_dynamic_font(READER_FONT_PATH)
	if error == OK:
		_reader_font = font
	else:
		push_warning("[rtv_lore_elements] Caveat font load failed: " + str(error))

func _register_read_hooks() -> void:
	_use_hook_id = _lib.hook("interface-use", _on_interface_use, 40)
	if _use_hook_id != -1:
		print("[rtv_lore_elements] registered interface-use reader hook.")
		return

	push_warning("[rtv_lore_elements] interface-use replace hook unavailable; trying interface-contextuse fallback.")
	_context_use_hook_id = _lib.hook("interface-contextuse", _on_interface_context_use, 40)
	if _context_use_hook_id != -1:
		print("[rtv_lore_elements] registered interface-contextuse reader hook.")
		return

	push_warning("[rtv_lore_elements] no reader replace hook available; lore notes will spawn without a Read action.")

func _register_ui_manager_input_hook() -> void:
	_ui_manager_input_hook_id = _lib.hook("uimanager-_input", _on_ui_manager_input, 40)
	if _ui_manager_input_hook_id != -1:
		print("[rtv_lore_elements] registered uimanager-_input reader cancel hook.")
	else:
		push_warning("[rtv_lore_elements] uimanager-_input hook unavailable; reader cancel relies on autoload input fallback.")

func _register_lore_content() -> void:
	var definitions := _load_note_definitions()
	if definitions.is_empty():
		push_warning("[rtv_lore_elements] no lore notes loaded; registering legacy note only.")
	else:
		for raw_definition in definitions:
			if typeof(raw_definition) != TYPE_DICTIONARY:
				push_warning("[rtv_lore_elements] skipping malformed note definition.")
				continue

			var definition: Dictionary = raw_definition
			var note_id := str(definition.get("id", ""))
			if note_id.is_empty():
				push_warning("[rtv_lore_elements] skipping note with missing id.")
				continue
			if _notes.has(note_id):
				push_warning("[rtv_lore_elements] duplicate lore note id skipped: " + note_id)
				continue

			var pages = definition.get("pages", [])
			if typeof(pages) != TYPE_ARRAY || pages.is_empty():
				push_warning("[rtv_lore_elements] skipping note with no pages: " + note_id)
				continue

			var item_data = _build_note_item(definition)
			if item_data == null:
				push_warning("[rtv_lore_elements] skipping note with missing item resource: " + note_id)
				continue

			var scene = _build_note_scene(note_id, item_data)
			if scene == null:
				push_warning("[rtv_lore_elements] skipping note with invalid pickup scene: " + note_id)
				continue

			_notes[note_id] = definition

			if !_lib.register(_lib.Registry.ITEMS, note_id, item_data):
				push_warning("[rtv_lore_elements] failed to register lore note item: " + note_id)

			if !_lib.register(_lib.Registry.SCENES, note_id, scene):
				push_warning("[rtv_lore_elements] failed to register lore note pickup scene: " + note_id)

			if !_lib.register(_lib.Registry.LOOT, note_id + "_in_master", {
				"item": item_data,
				"table": NOTE_LOOT_TABLE,
			}):
				push_warning("[rtv_lore_elements] failed to register lore note in LT_Master: " + note_id)

	_register_legacy_hello_note()
	print("[rtv_lore_elements] loaded " + str(_notes.size()) + " lore notes.")

func _register_legacy_hello_note() -> void:
	if _notes.has(LEGACY_HELLO_NOTE_ID):
		return

	var item_data = _build_note_item(LEGACY_HELLO_NOTE)
	var scene = _build_note_scene(LEGACY_HELLO_NOTE_ID, item_data)
	_notes[LEGACY_HELLO_NOTE_ID] = LEGACY_HELLO_NOTE

	if !_lib.register(_lib.Registry.ITEMS, LEGACY_HELLO_NOTE_ID, item_data):
		push_warning("[rtv_lore_elements] failed to register legacy hello note item.")

	if scene != null && !_lib.register(_lib.Registry.SCENES, LEGACY_HELLO_NOTE_ID, scene):
		push_warning("[rtv_lore_elements] failed to register legacy hello note pickup scene.")

func _load_note_definitions() -> Array:
	if !FileAccess.file_exists(NOTE_DATA_PATH):
		push_warning("[rtv_lore_elements] missing note data file: " + NOTE_DATA_PATH)
		return []

	var file := FileAccess.open(NOTE_DATA_PATH, FileAccess.READ)
	if file == null:
		push_warning("[rtv_lore_elements] failed to open note data file: " + NOTE_DATA_PATH)
		return []

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		push_warning("[rtv_lore_elements] note data file must contain a JSON array.")
		return []

	return parsed

func _build_note_item(definition: Dictionary):
	var note_id := str(definition["id"])
	var item_data = NOTE_ITEM_TEMPLATE
	if note_id != LEGACY_HELLO_NOTE_ID:
		var item_path := NOTE_ITEM_PATH_PREFIX + note_id + ".tres"
		item_data = load(item_path)
		if item_data == null:
			push_warning("[rtv_lore_elements] missing note item resource: " + item_path)
			return null

	item_data.file = note_id
	item_data.name = str(definition.get("name", note_id))
	item_data.inventory = str(definition.get("inventory", item_data.name))
	item_data.rotated = str(definition.get("rotated", item_data.inventory))
	item_data.equipment = str(definition.get("equipment", item_data.inventory))
	item_data.display = str(definition.get("display", item_data.inventory))
	item_data.type = "Lore"
	item_data.weight = float(definition.get("weight", 0.05))
	item_data.value = int(definition.get("value", 15))
	item_data.rarity = int(definition.get("rarity", 0))
	item_data.usable = _has_reader_hook()
	item_data.phrase = "Read"
	item_data.civilian = definition.get("civilian", false) == true
	item_data.industrial = definition.get("industrial", false) == true
	item_data.military = definition.get("military", false) == true
	return item_data

func _build_note_scene(note_id: String, item_data):
	var scene_instance = NOTE_SCENE_TEMPLATE.instantiate()
	if scene_instance == null:
		return null

	scene_instance.name = note_id
	var slot_data = scene_instance.get("slotData")
	if slot_data == null:
		scene_instance.free()
		return null

	var scene_slot_data = slot_data.duplicate(true)
	scene_slot_data.itemData = item_data
	scene_instance.set("slotData", scene_slot_data)
	_set_scene_owner(scene_instance, scene_instance)

	var packed_scene := PackedScene.new()
	var error := packed_scene.pack(scene_instance)
	scene_instance.free()
	if error != OK:
		push_warning("[rtv_lore_elements] PackedScene.pack failed for " + note_id + ": " + str(error))
		return null

	return packed_scene

func _set_scene_owner(node: Node, owner: Node) -> void:
	for child in node.get_children():
		child.owner = owner
		_set_scene_owner(child, owner)

func _has_reader_hook() -> bool:
	return _use_hook_id != -1 || _context_use_hook_id != -1

func _on_interface_use(target_item, _target_grid):
	var note_id := _get_note_id_from_item_node(target_item)
	if note_id.is_empty():
		return null

	var interface_node = _lib._caller
	_lib.skip_super()
	_reset_reader_interface_state(interface_node)
	_open_note_reader(note_id, interface_node)
	return null

func _on_interface_context_use():
	var interface_node = _lib._caller
	if interface_node == null:
		return null

	var note_id := _get_note_id_from_item_node(interface_node.contextItem)
	if note_id.is_empty():
		return null

	_lib.skip_super()
	interface_node.HideContext()
	interface_node.PlayClick()
	_reset_reader_interface_state(interface_node)
	_open_note_reader(note_id, interface_node)
	return null

func _on_ui_manager_input(event: InputEvent):
	if _reader && is_instance_valid(_reader) && _is_reader_cancel_event(event):
		get_viewport().set_input_as_handled()
		_close_reader()
		_lib.skip_super()

	return null

func _get_note_id_from_item_node(item_node) -> String:
	if item_node == null:
		return ""

	var slot_data = item_node.get("slotData")
	if slot_data == null || slot_data.itemData == null:
		return ""

	var note_id := str(slot_data.itemData.file)
	if !_notes.has(note_id):
		return ""

	return note_id

func _is_reader_cancel_event(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_cancel") || event.is_action_pressed("settings")

func _open_note_reader(note_id: String, interface_node: Node) -> void:
	if !_notes.has(note_id):
		push_warning("[rtv_lore_elements] no note text registered for " + note_id)
		return

	_close_reader()
	_reader_interface_node = interface_node
	_reader_note_id = note_id
	_reader_page_index = 0

	_reader = CanvasLayer.new()
	_reader.name = "RtvLoreNoteReader"
	_reader.layer = 100

	var overlay := ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0.02, 0.02, 0.018, 0.82)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_reader.add_child(overlay)

	var center := CenterContainer.new()
	center.name = "Center"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_reader.add_child(center)

	var panel := PanelContainer.new()
	panel.name = "Paper"
	panel.custom_minimum_size = Vector2(680, 500)
	panel.rotation_degrees = -1.1
	panel.pivot_offset = Vector2(340, 250)
	panel.add_theme_stylebox_override("panel", _build_paper_style())
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	margin.add_child(layout)

	_reader_title = Label.new()
	_reader_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reader_title.add_theme_color_override("font_color", Color(0.15, 0.12, 0.08))
	_reader_title.add_theme_font_size_override("font_size", 25)
	layout.add_child(_reader_title)

	_reader_body = RichTextLabel.new()
	_reader_body.bbcode_enabled = false
	_reader_body.fit_content = false
	_reader_body.scroll_active = true
	_reader_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reader_body.custom_minimum_size = Vector2(0, 330)
	_reader_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_reader_body.add_theme_color_override("default_color", Color(0.12, 0.1, 0.07))
	_reader_body.add_theme_font_size_override("normal_font_size", 27)
	if _reader_font != null:
		_reader_body.add_theme_font_override("normal_font", _reader_font)
	layout.add_child(_reader_body)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	layout.add_child(footer)

	_reader_prev_button = Button.new()
	_reader_prev_button.text = "Prev"
	_reader_prev_button.custom_minimum_size = Vector2(92, 34)
	_reader_prev_button.pressed.connect(_show_previous_page)
	footer.add_child(_reader_prev_button)

	_reader_page_counter = Label.new()
	_reader_page_counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reader_page_counter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_reader_page_counter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reader_page_counter.add_theme_color_override("font_color", Color(0.18, 0.14, 0.1))
	footer.add_child(_reader_page_counter)

	_reader_next_button = Button.new()
	_reader_next_button.text = "Next"
	_reader_next_button.custom_minimum_size = Vector2(92, 34)
	_reader_next_button.pressed.connect(_show_next_page)
	footer.add_child(_reader_next_button)

	var close_button := Button.new()
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(120, 36)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_button.pressed.connect(_close_reader)
	layout.add_child(close_button)

	var attach_parent := interface_node
	if attach_parent == null:
		attach_parent = get_tree().current_scene
	attach_parent.add_child(_reader)
	_refresh_reader_page()

func _build_paper_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.78, 0.72, 0.58)
	style.border_color = Color(0.36, 0.27, 0.16)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.36)
	style.shadow_size = 18
	style.shadow_offset = Vector2(0, 5)
	return style

func _show_previous_page() -> void:
	if _reader_page_index <= 0:
		return
	_reader_page_index -= 1
	_refresh_reader_page()

func _show_next_page() -> void:
	var pages := _get_reader_pages()
	if _reader_page_index >= pages.size() - 1:
		return
	_reader_page_index += 1
	_refresh_reader_page()

func _refresh_reader_page() -> void:
	if !_reader || !is_instance_valid(_reader) || !_notes.has(_reader_note_id):
		return

	var note = _notes[_reader_note_id]
	var pages := _get_reader_pages()
	if pages.is_empty():
		return

	_reader_page_index = clampi(_reader_page_index, 0, pages.size() - 1)
	_reader_title.text = str(note.get("name", _reader_note_id))
	_reader_body.text = str(pages[_reader_page_index])
	_reader_page_counter.text = str(_reader_page_index + 1) + " / " + str(pages.size())
	_reader_prev_button.disabled = _reader_page_index <= 0
	_reader_next_button.disabled = _reader_page_index >= pages.size() - 1
	_reader_body.call_deferred("scroll_to_line", 0)

func _get_reader_pages() -> Array:
	if !_notes.has(_reader_note_id):
		return []
	var pages = _notes[_reader_note_id].get("pages", [])
	if typeof(pages) != TYPE_ARRAY:
		return []
	return pages

func _close_reader() -> void:
	if _reader && is_instance_valid(_reader):
		_reader.queue_free()
	_reset_reader_interface_state(_reader_interface_node)
	_reader = null
	_reader_interface_node = null
	_reader_note_id = ""
	_reader_page_index = 0
	_reader_title = null
	_reader_body = null
	_reader_page_counter = null
	_reader_prev_button = null
	_reader_next_button = null

func _reset_reader_interface_state(interface_node: Node) -> void:
	if interface_node == null || !is_instance_valid(interface_node):
		return

	var game_data = interface_node.get("gameData")
	if game_data != null:
		game_data.isOccupied = false

	if interface_node.has_method("HideContext"):
		interface_node.HideContext()
	if interface_node.has_method("Reset"):
		interface_node.Reset()
	if interface_node.has_method("ResetInput"):
		interface_node.ResetInput()
