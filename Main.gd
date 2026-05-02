# Lore Elements — Main autoload entry point.
# See PLANNING.md for project context, architecture, and phased roadmap.
extends Node

const NOTE_DATA_PATH := "res://rtv-lore-elements/data/notes.json"
const NOTE_ITEM_PATH_PREFIX := "res://rtv-lore-elements/Items/Lore/Notes/"
const LEGACY_NOTE_ITEM_PATH := "res://rtv-lore-elements/Items/Lore/Note_HelloWorld/Note_HelloWorld.tres"
const JOURNAL_DATA_PATH := "user://lore-elements-journal.cfg"
const JOURNAL_INPUT_ACTION := "rtv_lore_open_journal"
const READER_FONT_PATH := "res://rtv-lore-elements/assets/fonts/Caveat-Regular.ttf"
const NOTE_LOOT_TABLE := "LT_Master"
const MCM_HELPERS_PATH := "res://ModConfigurationMenu/Scripts/Doink Oink/MCM_Helpers.tres"
const MCM_MOD_ID := "rtv_lore_elements"
const MCM_CONFIG_DIR := "user://MCM/rtv_lore_elements"
const MCM_CONFIG_FILE := MCM_CONFIG_DIR + "/config.ini"
const MCM_SPAWN_MULTIPLIER_KEY := "lore_note_spawn_multiplier"
const MCM_JOURNAL_HOTKEY_KEY := "lore_journal_hotkey"
const DEFAULT_LORE_NOTE_SPAWN_MULTIPLIER := 1.0
const DEFAULT_JOURNAL_HOTKEY := KEY_J
const DEFAULT_JOURNAL_HOTKEY_TYPE := "Key"
const LEGACY_HELLO_NOTE_ID := "rtv_lore_hello_note"
const LEGACY_HELLO_NOTE := {
	"id": LEGACY_HELLO_NOTE_ID,
	"name": "Damaged Field Note",
	"inventory": "Field Note",
	"rotated": "Field Note",
	"equipment": "F. Note",
	"display": "F. Note",
	"rarity": 1,
	"value": 25,
	"civilian": true,
	"industrial": true,
	"military": true,
	"pages": [
		"Day 11 after the border closed.\n\nThe checkpoint lights still blink at night, but no one answers the radio. We found boot tracks by the birch line and three spent casings in the snow.",
		"Someone came through here after the evacuation order.\n\nIf this reaches the cabin, tell Leena I kept the brass compass. It points north even when everything else lies."
	]
}

var GAME_DATA = preload("res://Resources/GameData.tres")
var NOTE_SCENE_TEMPLATE = preload("res://rtv-lore-elements/Items/Lore/Note_HelloWorld/Note_HelloWorld.tscn")

var _lib = null
var _use_hook_id := -1
var _context_use_hook_id := -1
var _ui_manager_input_hook_id := -1
var _auto_place_hook_id := -1
var _lootcontainer_fill_buckets_hook_id := -1
var _lootsimulation_fill_buckets_hook_id := -1

var _notes := {}
var _reader_font = null
var _mcm_helpers = null
var _lore_note_spawn_multiplier := DEFAULT_LORE_NOTE_SPAWN_MULTIPLIER
var _journal_hotkey_value := DEFAULT_JOURNAL_HOTKEY
var _journal_hotkey_type := DEFAULT_JOURNAL_HOTKEY_TYPE

var _journal_discovered_ids: Array = []
var _journal_read_ids: Array = []
var _journal: CanvasLayer = null
var _journal_interface_node: Node = null
var _journal_list: VBoxContainer = null
var _journal_input_repaired := false
var _modal_controls_active := false
var _modal_previous_mouse_mode := Input.MOUSE_MODE_CAPTURED
var _modal_previous_freeze := false

var _reader: CanvasLayer = null
var _reader_interface_node: Node = null
var _reader_note_id := ""
var _reader_page_index := 0
var _reader_title: Label = null
var _reader_body: RichTextLabel = null
var _reader_page_counter: Label = null
var _reader_prev_button: Button = null
var _reader_next_button: Button = null
var _reader_from_journal := false

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
	if _reader && is_instance_valid(_reader):
		if _is_journal_toggle_event(event) || _is_reader_cancel_event(event):
			get_viewport().set_input_as_handled()
			_close_reader()
		return

	if _journal && is_instance_valid(_journal):
		if _is_journal_toggle_event(event) || _is_reader_cancel_event(event):
			get_viewport().set_input_as_handled()
			_close_journal()
		return

	if _is_journal_toggle_event(event) && _can_toggle_journal():
		get_viewport().set_input_as_handled()
		_open_journal(_get_active_interface_node())
		return

func _on_lib_ready() -> void:
	_lib = Engine.get_meta("RTVModLib")
	print("[rtv_lore_elements] frameworks ready, registering...")
	_load_reader_font()
	if _reader_font == null:
		push_warning("[rtv_lore_elements] Caveat font unavailable; reader will use the default UI font.")
	_register_read_hooks()
	_register_ui_manager_input_hook()
	_register_discovery_hooks()
	_register_journal_input()
	_register_mcm_config()
	_register_loot_multiplier_hooks()
	_register_lore_content()
	_load_journal()

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

func _register_discovery_hooks() -> void:
	_auto_place_hook_id = _lib.hook("interface-autoplace-post", _on_interface_auto_place_post, 40)
	if _auto_place_hook_id != -1:
		print("[rtv_lore_elements] registered interface-autoplace-post journal discovery hook.")
	else:
		push_warning("[rtv_lore_elements] interface-autoplace-post hook unavailable; journal discovery relies on reader-open fallback.")

func _register_loot_multiplier_hooks() -> void:
	_lootcontainer_fill_buckets_hook_id = _lib.hook("lootcontainer-fillbuckets-post", _on_loot_fill_buckets_post, 40)
	if _lootcontainer_fill_buckets_hook_id != -1:
		print("[rtv_lore_elements] registered lootcontainer-fillbuckets-post spawn multiplier hook.")
	else:
		push_warning("[rtv_lore_elements] lootcontainer-fillbuckets-post hook unavailable; MCM spawn multiplier will not affect containers.")

	_lootsimulation_fill_buckets_hook_id = _lib.hook("lootsimulation-fillbuckets-post", _on_loot_fill_buckets_post, 40)
	if _lootsimulation_fill_buckets_hook_id != -1:
		print("[rtv_lore_elements] registered lootsimulation-fillbuckets-post spawn multiplier hook.")
	else:
		push_warning("[rtv_lore_elements] lootsimulation-fillbuckets-post hook unavailable; MCM spawn multiplier will not affect loose loot.")

func _register_journal_input() -> void:
	if _lib.register(_lib.Registry.INPUTS, JOURNAL_INPUT_ACTION, {
		"display_label": "Open Lore Journal",
		"default_event": _create_journal_input_event(),
	}):
		print("[rtv_lore_elements] registered journal input: " + JOURNAL_INPUT_ACTION)
	elif InputMap.has_action(JOURNAL_INPUT_ACTION):
		print("[rtv_lore_elements] journal input already registered: " + JOURNAL_INPUT_ACTION)
	else:
		push_warning("[rtv_lore_elements] failed to register journal input: " + JOURNAL_INPUT_ACTION)

func _register_mcm_config() -> void:
	var config := _build_default_mcm_config()
	if FileAccess.file_exists(MCM_CONFIG_FILE):
		config.load(MCM_CONFIG_FILE)

	if ResourceLoader.exists(MCM_HELPERS_PATH):
		_mcm_helpers = load(MCM_HELPERS_PATH)

	if _mcm_helpers != null:
		if !FileAccess.file_exists(MCM_CONFIG_FILE):
			_ensure_mcm_config_dir()
			var save_error := config.save(MCM_CONFIG_FILE)
			if save_error != OK:
				push_warning("[rtv_lore_elements] failed to create MCM config: " + str(save_error))
		else:
			_mcm_helpers.CheckConfigurationHasUpdated(MCM_MOD_ID, _build_default_mcm_config(), MCM_CONFIG_FILE)
			config.load(MCM_CONFIG_FILE)

		_mcm_helpers.RegisterConfiguration(
			MCM_MOD_ID,
			"Lore Elements",
			MCM_CONFIG_DIR,
			"Configure lore note spawn rate and the lore journal hotkey.",
			{
				"config.ini": _on_mcm_config_updated
			},
			self
		)
		print("[rtv_lore_elements] registered MCM configuration.")
	else:
		print("[rtv_lore_elements] MCM not installed; using default Lore Elements config.")

	_apply_mcm_config(config)

func _build_default_mcm_config() -> ConfigFile:
	var config := ConfigFile.new()
	config.set_value("Float", MCM_SPAWN_MULTIPLIER_KEY, {
		"name": "Lore note spawn rate",
		"tooltip": "Multiplies how often Lore Elements notes appear in newly generated loot.",
		"default": DEFAULT_LORE_NOTE_SPAWN_MULTIPLIER,
		"value": DEFAULT_LORE_NOTE_SPAWN_MULTIPLIER,
		"minRange": 0.0,
		"maxRange": 3.0,
		"step": 0.1,
		"menu_pos": 1,
		"on_value_changed": "_on_mcm_value_changed"
	})
	config.set_value("Keycode", MCM_JOURNAL_HOTKEY_KEY, {
		"name": "Journal hotkey",
		"tooltip": "Opens the Lore Elements journal.",
		"default": DEFAULT_JOURNAL_HOTKEY,
		"default_type": DEFAULT_JOURNAL_HOTKEY_TYPE,
		"value": DEFAULT_JOURNAL_HOTKEY,
		"type": DEFAULT_JOURNAL_HOTKEY_TYPE,
		"menu_pos": 2,
		"on_value_changed": "_on_mcm_value_changed"
	})
	return config

func _ensure_mcm_config_dir() -> void:
	var user_dir := DirAccess.open("user://")
	if user_dir != null:
		user_dir.make_dir_recursive("MCM/rtv_lore_elements")

func _on_mcm_config_updated(config: ConfigFile) -> void:
	_apply_mcm_config(config)
	print("[rtv_lore_elements] MCM configuration updated.")

func _on_mcm_value_changed(value_id: String, new_value, _menu) -> void:
	if value_id == MCM_SPAWN_MULTIPLIER_KEY:
		_lore_note_spawn_multiplier = clampf(float(new_value), 0.0, 3.0)
	elif value_id == MCM_JOURNAL_HOTKEY_KEY:
		_apply_journal_hotkey_event(new_value)

func _apply_mcm_config(config: ConfigFile) -> void:
	_lore_note_spawn_multiplier = clampf(float(_get_mcm_entry_value(config, "Float", MCM_SPAWN_MULTIPLIER_KEY, DEFAULT_LORE_NOTE_SPAWN_MULTIPLIER)), 0.0, 3.0)
	var hotkey_data := _get_mcm_keycode(config, MCM_JOURNAL_HOTKEY_KEY, DEFAULT_JOURNAL_HOTKEY, DEFAULT_JOURNAL_HOTKEY_TYPE)
	_journal_hotkey_value = int(hotkey_data[0])
	_journal_hotkey_type = str(hotkey_data[1])
	if _journal_hotkey_type != "Mouse":
		_journal_hotkey_type = "Key"
	_sync_journal_input_action()

func _apply_journal_hotkey_event(event) -> void:
	if event is InputEventMouseButton:
		_journal_hotkey_value = event.button_index
		_journal_hotkey_type = "Mouse"
		_sync_journal_input_action()
	elif event is InputEventKey:
		_journal_hotkey_value = event.physical_keycode
		if _journal_hotkey_value == 0:
			_journal_hotkey_value = event.keycode
		_journal_hotkey_type = "Key"
		_sync_journal_input_action()

func _get_mcm_entry_value(config: ConfigFile, section: String, key: String, fallback):
	var entry = config.get_value(section, key, null)
	if typeof(entry) != TYPE_DICTIONARY:
		return fallback
	return entry.get("value", fallback)

func _get_mcm_keycode(config: ConfigFile, key: String, fallback_value: int, fallback_type: String) -> Array:
	var entry = config.get_value("Keycode", key, null)
	if typeof(entry) != TYPE_DICTIONARY:
		return [fallback_value, fallback_type]
	return [entry.get("value", fallback_value), entry.get("type", fallback_type)]

func _create_journal_input_event(key_value := DEFAULT_JOURNAL_HOTKEY, key_type := DEFAULT_JOURNAL_HOTKEY_TYPE) -> InputEvent:
	if key_type == "Mouse":
		var mouse_event := InputEventMouseButton.new()
		mouse_event.button_index = int(key_value)
		return mouse_event

	var key_event := InputEventKey.new()
	key_event.keycode = int(key_value)
	key_event.physical_keycode = int(key_value)
	return key_event

func _sync_journal_input_action() -> void:
	if !InputMap.has_action(JOURNAL_INPUT_ACTION):
		InputMap.add_action(JOURNAL_INPUT_ACTION)
	else:
		InputMap.action_erase_events(JOURNAL_INPUT_ACTION)

	InputMap.action_add_event(JOURNAL_INPUT_ACTION, _create_journal_input_event(_journal_hotkey_value, _journal_hotkey_type))

func _ensure_journal_input_action() -> bool:
	if InputMap.has_action(JOURNAL_INPUT_ACTION) && !InputMap.action_get_events(JOURNAL_INPUT_ACTION).is_empty():
		return false

	_sync_journal_input_action()
	if !_journal_input_repaired:
		push_warning("[rtv_lore_elements] journal input action was missing; repaired direct InputMap binding.")
		_journal_input_repaired = true
	return true

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
	if item_data == null:
		push_warning("[rtv_lore_elements] skipping legacy hello note with missing item resource.")
		return

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
	var item_path := LEGACY_NOTE_ITEM_PATH
	if note_id != LEGACY_HELLO_NOTE_ID:
		item_path = NOTE_ITEM_PATH_PREFIX + note_id + ".tres"

	var item_data = ResourceLoader.load(item_path, "", ResourceLoader.CACHE_MODE_IGNORE)
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
	if _reader && is_instance_valid(_reader):
		if _is_journal_toggle_event(event) || _is_reader_cancel_event(event):
			get_viewport().set_input_as_handled()
			_close_reader()
		_lib.skip_super()
		return null

	if _journal && is_instance_valid(_journal):
		if _is_journal_toggle_event(event) || _is_reader_cancel_event(event):
			get_viewport().set_input_as_handled()
			_close_journal()
		_lib.skip_super()
		return null

	if _is_journal_toggle_event(event) && _can_toggle_journal():
		get_viewport().set_input_as_handled()
		_open_journal(_get_active_interface_node())
		_lib.skip_super()
		return null

	return null

func _on_interface_auto_place_post(target_item, target_grid, _source_grid, _usedrop):
	var interface_node = _lib._caller
	if interface_node == null || target_grid == null:
		return null

	var inventory_grid = interface_node.get("inventoryGrid")
	if inventory_grid == null || target_grid != inventory_grid:
		return null

	var note_id := _get_note_id_from_item_node(target_item)
	if !note_id.is_empty():
		_record_note_discovered(note_id, true)

	return null

func _on_loot_fill_buckets_post():
	_apply_lore_spawn_multiplier_to_buckets(_lib._caller)
	return null

func _apply_lore_spawn_multiplier_to_buckets(bucket_owner) -> void:
	if bucket_owner == null || !is_instance_valid(bucket_owner):
		return
	if is_equal_approx(_lore_note_spawn_multiplier, 1.0):
		return

	for bucket_name in ["commonBucket", "rareBucket", "legendaryBucket"]:
		var bucket = bucket_owner.get(bucket_name)
		if typeof(bucket) != TYPE_ARRAY:
			continue

		var adjusted_bucket: Array[ItemData] = []
		for item_data in bucket:
			if !_is_lore_note_item_data(item_data):
				adjusted_bucket.append(item_data)
				continue

			_append_lore_note_by_multiplier(adjusted_bucket, item_data)

		bucket_owner.set(bucket_name, adjusted_bucket)

func _append_lore_note_by_multiplier(bucket: Array, item_data) -> void:
	if _lore_note_spawn_multiplier <= 0.0:
		return

	if _lore_note_spawn_multiplier < 1.0:
		if randf() < _lore_note_spawn_multiplier:
			bucket.append(item_data)
		return

	bucket.append(item_data)
	var guaranteed_extra := int(floor(_lore_note_spawn_multiplier)) - 1
	for _index in guaranteed_extra:
		bucket.append(item_data)

	var fractional_extra := _lore_note_spawn_multiplier - floor(_lore_note_spawn_multiplier)
	if fractional_extra > 0.0 && randf() < fractional_extra:
		bucket.append(item_data)

func _is_lore_note_item_data(item_data) -> bool:
	if item_data == null:
		return false
	return _notes.has(str(item_data.file))

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

func _is_journal_toggle_event(event: InputEvent) -> bool:
	var repaired_action := _ensure_journal_input_action()
	if InputMap.has_action(JOURNAL_INPUT_ACTION) && event.is_action_pressed(JOURNAL_INPUT_ACTION):
		return true

	if repaired_action:
		return _event_matches_journal_hotkey(event)

	return false

func _event_matches_journal_hotkey(event: InputEvent) -> bool:
	if _journal_hotkey_type == "Mouse":
		return event is InputEventMouseButton && event.pressed && event.button_index == _journal_hotkey_value

	if event is InputEventKey:
		var key_event := event as InputEventKey
		return key_event.pressed && !key_event.echo && (key_event.keycode == _journal_hotkey_value || key_event.physical_keycode == _journal_hotkey_value)

	return false

func _is_reader_cancel_event(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_cancel") || event.is_action_pressed("settings")

func _can_toggle_journal() -> bool:
	if _reader && is_instance_valid(_reader):
		return false
	if get_node_or_null("/root/Map") == null:
		return false
	if GAME_DATA.isDead || GAME_DATA.isCaching || GAME_DATA.isTransitioning:
		return false
	if GAME_DATA.isReloading || GAME_DATA.isInserting || GAME_DATA.isChecking:
		return false
	if GAME_DATA.isPlacing || GAME_DATA.isSleeping || GAME_DATA.isInspecting:
		return false
	if GAME_DATA.settings:
		return false
	return true

func _get_active_interface_node() -> Node:
	return get_node_or_null("/root/Map/Core/UI/Interface")

func _open_note_reader(note_id: String, interface_node: Node, from_journal := false) -> void:
	if !_notes.has(note_id):
		push_warning("[rtv_lore_elements] no note text registered for " + note_id)
		return

	_record_note_read(note_id, true)
	if _journal && is_instance_valid(_journal):
		_populate_journal_entries()
	_close_reader()
	_acquire_modal_controls()
	_reader_interface_node = interface_node
	_reader_note_id = note_id
	_reader_page_index = 0
	_reader_from_journal = from_journal

	_reader = CanvasLayer.new()
	_reader.name = "RtvLoreNoteReader"
	_reader.layer = 140

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

	var attach_parent := _get_overlay_attach_parent(interface_node)
	attach_parent.add_child(_reader)
	_refresh_reader_page()

func _load_journal() -> void:
	_journal_discovered_ids = []
	_journal_read_ids = []

	var config := ConfigFile.new()
	var error := config.load(JOURNAL_DATA_PATH)
	if error == ERR_FILE_NOT_FOUND:
		return
	if error != OK:
		push_warning("[rtv_lore_elements] journal config failed to load; starting empty: " + str(error))
		return

	_journal_discovered_ids = _sanitize_journal_ids(config.get_value("journal", "discovered_ids", []))
	_journal_read_ids = _sanitize_journal_ids(config.get_value("journal", "read_ids", []))
	_prune_read_ids_to_discovered()

func _sanitize_journal_ids(raw_ids) -> Array:
	var clean_ids: Array = []
	if typeof(raw_ids) != TYPE_ARRAY && typeof(raw_ids) != TYPE_PACKED_STRING_ARRAY:
		return clean_ids

	for raw_id in raw_ids:
		var note_id := str(raw_id)
		if note_id.is_empty() || clean_ids.has(note_id):
			continue
		clean_ids.append(note_id)
	return clean_ids

func _prune_read_ids_to_discovered() -> void:
	var pruned: Array = []
	for note_id in _journal_read_ids:
		if _journal_discovered_ids.has(note_id) && !pruned.has(note_id):
			pruned.append(note_id)
	_journal_read_ids = pruned

func _save_journal() -> void:
	_prune_read_ids_to_discovered()
	var config := ConfigFile.new()
	config.set_value("journal", "discovered_ids", _journal_discovered_ids)
	config.set_value("journal", "read_ids", _journal_read_ids)
	var error := config.save(JOURNAL_DATA_PATH)
	if error != OK:
		push_warning("[rtv_lore_elements] journal config failed to save: " + str(error))

func _record_note_discovered(note_id: String, should_save: bool) -> bool:
	if note_id.is_empty() || !_notes.has(note_id):
		return false

	var changed := false
	if !_journal_discovered_ids.has(note_id):
		_journal_discovered_ids.append(note_id)
		changed = true

	if should_save && changed:
		_save_journal()
	return changed

func _record_note_read(note_id: String, should_save: bool) -> bool:
	if note_id.is_empty() || !_notes.has(note_id):
		return false

	var changed := _record_note_discovered(note_id, false)
	if !_journal_read_ids.has(note_id):
		_journal_read_ids.append(note_id)
		changed = true

	if should_save && changed:
		_save_journal()
	return changed

func _open_journal(interface_node: Node) -> void:
	_close_journal()
	_acquire_modal_controls()
	_journal_interface_node = interface_node

	_journal = CanvasLayer.new()
	_journal.name = "RtvLoreJournal"
	_journal.layer = 120

	var overlay := ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0.02, 0.02, 0.018, 0.76)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_journal.add_child(overlay)

	var center := CenterContainer.new()
	center.name = "Center"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_journal.add_child(center)

	var panel := PanelContainer.new()
	panel.name = "JournalPanel"
	panel.custom_minimum_size = Vector2(560, 500)
	panel.add_theme_stylebox_override("panel", _build_journal_style())
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	var title := Label.new()
	title.text = "Journal"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.86, 0.82, 0.72))
	title.add_theme_font_size_override("font_size", 26)
	layout.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 360)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)

	_journal_list = VBoxContainer.new()
	_journal_list.add_theme_constant_override("separation", 8)
	_journal_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_journal_list)

	_populate_journal_entries()

	var close_button := Button.new()
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(120, 36)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_button.pressed.connect(_close_journal)
	layout.add_child(close_button)

	var attach_parent := _get_overlay_attach_parent(interface_node)
	attach_parent.add_child(_journal)

func _get_overlay_attach_parent(interface_node: Node) -> Node:
	if interface_node != null && is_instance_valid(interface_node) && interface_node.is_visible_in_tree():
		return interface_node
	if get_tree().current_scene != null:
		return get_tree().current_scene
	return self

func _build_journal_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.12, 0.1)
	style.border_color = Color(0.48, 0.39, 0.25)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	style.shadow_size = 16
	style.shadow_offset = Vector2(0, 4)
	return style

func _populate_journal_entries() -> void:
	if _journal_list == null:
		return

	for child in _journal_list.get_children():
		child.queue_free()

	var rendered_count := 0
	for index in range(_journal_discovered_ids.size() - 1, -1, -1):
		var note_id := str(_journal_discovered_ids[index])
		if !_notes.has(note_id):
			continue

		var note = _notes[note_id]
		var entry := Button.new()
		entry.text = _format_journal_entry_label(note_id, str(note.get("name", note_id)))
		entry.alignment = HORIZONTAL_ALIGNMENT_LEFT
		entry.custom_minimum_size = Vector2(0, 38)
		entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		entry.pressed.connect(_open_note_from_journal.bind(note_id))
		_journal_list.add_child(entry)
		rendered_count += 1

	if rendered_count == 0:
		var empty := Label.new()
		empty.text = "No notes discovered yet."
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.add_theme_color_override("font_color", Color(0.68, 0.64, 0.55))
		empty.add_theme_font_size_override("font_size", 18)
		_journal_list.add_child(empty)

func _format_journal_entry_label(note_id: String, note_name: String) -> String:
	if _journal_read_ids.has(note_id):
		return "  " + note_name
	return "* " + note_name

func _open_note_from_journal(note_id: String) -> void:
	var interface_node = _journal_interface_node
	_open_note_reader(note_id, interface_node, true)

func _close_journal(should_release_controls := true, should_save := true) -> void:
	var had_journal := _journal && is_instance_valid(_journal)
	if _journal && is_instance_valid(_journal):
		_journal.queue_free()
	if had_journal && should_release_controls:
		_release_modal_controls()
	if had_journal && should_save:
		_save_journal()
	_journal = null
	_journal_interface_node = null
	_journal_list = null

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
	var had_reader := _reader && is_instance_valid(_reader)
	if _reader && is_instance_valid(_reader):
		_reader.queue_free()
	if !_reader_from_journal:
		_reset_reader_interface_state(_reader_interface_node)
	if had_reader:
		if _journal && is_instance_valid(_journal):
			_populate_journal_entries()
		else:
			_release_modal_controls()
		_save_journal()
	_reader = null
	_reader_interface_node = null
	_reader_note_id = ""
	_reader_page_index = 0
	_reader_title = null
	_reader_body = null
	_reader_page_counter = null
	_reader_prev_button = null
	_reader_next_button = null
	_reader_from_journal = false

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

func _acquire_modal_controls() -> void:
	if _modal_controls_active:
		return

	_modal_previous_mouse_mode = Input.get_mouse_mode()
	_modal_previous_freeze = GAME_DATA.freeze
	GAME_DATA.freeze = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	_modal_controls_active = true

func _release_modal_controls() -> void:
	if !_modal_controls_active:
		return

	GAME_DATA.freeze = _modal_previous_freeze
	Input.set_mouse_mode(_modal_previous_mouse_mode)
	_modal_controls_active = false
	_modal_previous_mouse_mode = Input.MOUSE_MODE_CAPTURED
	_modal_previous_freeze = false
