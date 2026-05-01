# Lore Elements — Main autoload entry point.
# See PLANNING.md for project context, architecture, and phased roadmap.
extends Node

const HELLO_NOTE_ID := "rtv_lore_hello_note"
const HELLO_NOTE_LOOT_HANDLE := "rtv_lore_hello_note_in_master"
var HELLO_NOTE_ITEM = preload("res://rtv-lore-elements/Items/Lore/Note_HelloWorld/Note_HelloWorld.tres")
var HELLO_NOTE_SCENE = preload("res://rtv-lore-elements/Items/Lore/Note_HelloWorld/Note_HelloWorld.tscn")

const NOTE_TEXT := {
	"rtv_lore_hello_note": {
		"title": "Damaged Field Note",
		"body": "Day 11 after the border closed.\n\nThe checkpoint lights still blink at night, but no one answers the radio. We found boot tracks by the birch line and three spent casings in the snow. Someone came through here after the evacuation order.\n\nIf this reaches the cabin, tell Leena I kept the brass compass. It points north even when everything else lies."
	}
}

var _lib = null
var _use_hook_id := -1
var _context_use_hook_id := -1
var _reader: CanvasLayer = null

func _ready() -> void:
	if Engine.has_meta("RTVModLib"):
		var lib = Engine.get_meta("RTVModLib")
		if lib._is_ready:
			_on_lib_ready()
		else:
			lib.frameworks_ready.connect(_on_lib_ready)
	else:
		push_warning("[rtv_lore_elements] RTVModLib meta not present - Metro Mod Loader required.")

func _unhandled_input(event: InputEvent) -> void:
	if _reader && is_instance_valid(_reader) && event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close_reader()

func _on_lib_ready() -> void:
	_lib = Engine.get_meta("RTVModLib")
	print("[rtv_lore_elements] frameworks ready, registering...")
	_register_read_hooks()
	_register_lore_content()

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

	HELLO_NOTE_ITEM.usable = false
	push_warning("[rtv_lore_elements] no reader replace hook available; hello note will spawn without a Read action.")

func _register_lore_content() -> void:
	if !_lib.register(_lib.Registry.ITEMS, HELLO_NOTE_ID, HELLO_NOTE_ITEM):
		push_warning("[rtv_lore_elements] failed to register hello note item.")

	if !_lib.register(_lib.Registry.SCENES, HELLO_NOTE_ID, HELLO_NOTE_SCENE):
		push_warning("[rtv_lore_elements] failed to register hello note pickup scene.")

	if !_lib.register(_lib.Registry.LOOT, HELLO_NOTE_LOOT_HANDLE, {
		"item": HELLO_NOTE_ITEM,
		"table": "LT_Master",
	}):
		push_warning("[rtv_lore_elements] failed to register hello note in LT_Master.")

func _on_interface_use(target_item, _target_grid):
	if !_is_hello_note_item(target_item):
		return null

	_lib.skip_super()
	_open_note_reader(HELLO_NOTE_ID, _lib._caller)
	return null

func _on_interface_context_use():
	var interface_node = _lib._caller
	if interface_node == null || !_is_hello_note_item(interface_node.contextItem):
		return null

	_lib.skip_super()
	interface_node.HideContext()
	interface_node.PlayClick()
	_open_note_reader(HELLO_NOTE_ID, interface_node)
	return null

func _is_hello_note_item(item_node) -> bool:
	if item_node == null:
		return false

	var slot_data = item_node.get("slotData")
	if slot_data == null || slot_data.itemData == null:
		return false

	return slot_data.itemData.file == HELLO_NOTE_ID

func _open_note_reader(note_id: String, interface_node: Node) -> void:
	if !NOTE_TEXT.has(note_id):
		push_warning("[rtv_lore_elements] no note text registered for " + note_id)
		return

	_close_reader()

	var note = NOTE_TEXT[note_id]
	_reader = CanvasLayer.new()
	_reader.name = "RtvLoreNoteReader"
	_reader.layer = 100

	var overlay := ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0.02, 0.02, 0.018, 0.78)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_reader.add_child(overlay)

	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -320.0
	panel.offset_top = -230.0
	panel.offset_right = 320.0
	panel.offset_bottom = 230.0
	_reader.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	margin.add_child(layout)

	var title := Label.new()
	title.text = note["title"]
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	layout.add_child(title)

	var body := RichTextLabel.new()
	body.bbcode_enabled = false
	body.text = note["body"]
	body.fit_content = false
	body.scroll_active = true
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(body)

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

func _close_reader() -> void:
	if _reader && is_instance_valid(_reader):
		_reader.queue_free()
	_reader = null
