# Lore Elements — Main autoload entry point.
# See PLANNING.md for project context, architecture, and phased roadmap.
extends Node

# Awake custom paper pickups need a rendered-contact skin and containment.
# Keeping this child under the body gives automatic cleanup; sleep/preview stops
# both loops. Native wake and a subsequent release rearm the same helper.
class PaperContactPresenter extends Node:
	var coordinator: WeakRef
	var base_mesh_position := Vector3.ZERO
	var wall_previous := Transform3D.IDENTITY
	var wall_tracking := false
	var wall_offsets: Array = []
	var wall_planes: Array = []

	func _physics_process(_delta: float) -> void:
		var host = coordinator.get_ref() if coordinator != null else null
		if !is_instance_valid(host):
			set_physics_process(false)
			return
		host._contain_world_pickup_motion(get_parent(), self)

	func _process(_delta: float) -> void:
		var host = coordinator.get_ref() if coordinator != null else null
		if !is_instance_valid(host):
			set_process(false)
			return
		host._present_world_pickup_contact(get_parent(), self)

const NOTE_DATA_PATH := "res://rtv-lore-elements/data/notes.json"
const NOTE_TYPE_DATA_PATH := "res://rtv-lore-elements/data/note_types.json"
const UI_STRINGS_PATH := "res://rtv-lore-elements/data/strings/en.json"
const UI_STRINGS_LOCALE := "en"
const NOTE_ITEM_PATH_PREFIX := "res://rtv-lore-elements/Items/Lore/Notes/"
const LEGACY_NOTE_ITEM_PATH := "res://rtv-lore-elements/Items/Lore/Note_HelloWorld/Note_HelloWorld.tres"
const HAMINA_NOTE_ID := "rtv_lore_hamina_last_shift"
const TRIAGE_NOTE_IDS := [
	"rtv_lore_clinic_triage_card",
	"rtv_lore_triage_unknown_male",
]
const NOTEBOOK_NOTE_IDS := [
	"rtv_lore_forest_cache_note", "rtv_lore_weathered_recipe", "rtv_lore_guard_three_lines",
]
const NOTEBOOK_PORTRAIT_ITEM_PREFIX := "res://rtv-lore-elements/Items/Lore/TornNotebook/Portrait/"
const FOLDED_NOTE_IDS := [
	"rtv_lore_border_shift_log", "rtv_lore_radio_transcript",
	"rtv_lore_last_letter_leena", "rtv_lore_letter_tampere",
]
const FOLDED_COMPACT_ITEM_PREFIX := "res://rtv-lore-elements/Items/Lore/FoldedDocument/Compact/"
const HAMINA_PICKUP_MESH_PATH := "res://rtv-lore-elements/assets/models/hamina_dispatch_mesh.tres"
const HAMINA_PICKUP_ALBEDO_PATH := "res://rtv-lore-elements/assets/textures/hamina_dispatch_albedo.png"
const TRIAGE_PICKUP_MESH_PATH := "res://rtv-lore-elements/assets/models/triage_card_blender_v001.tres"
const TRIAGE_PICKUP_ALBEDO_PATH := "res://rtv-lore-elements/assets/textures/triage_clinic_ink_v001.png"
const WORLD_ITEM_SHADER_PATH := "res://Shaders/Standard.gdshader"
const HAMINA_PICKUP_WORLD_SCALE := 1.3
const HAMINA_PICKUP_MIN_DIMENSIONS := Vector3(0.14, 0.001, 0.09)
const HAMINA_PICKUP_MAX_DIMENSIONS := Vector3(0.16, 0.004, 0.11)
const HAMINA_PICKUP_ALBEDO_SIZE := Vector2i(512, 512)
const WORLD_PICKUP_VARIANT_DEFINITIONS := {
	"hamina_dispatch": {
		"display_name": "Hamina dispatch",
		"note_ids": [HAMINA_NOTE_ID],
		"mesh_path": HAMINA_PICKUP_MESH_PATH,
		"albedo_path": HAMINA_PICKUP_ALBEDO_PATH,
		"albedo_size": HAMINA_PICKUP_ALBEDO_SIZE,
		"world_scale": HAMINA_PICKUP_WORLD_SCALE,
		"minimum_dimensions": HAMINA_PICKUP_MIN_DIMENSIONS,
		"maximum_dimensions": HAMINA_PICKUP_MAX_DIMENSIONS,
		"stabilize_drops": true,
	},
	"triage_tag": {
		"display_name": "triage tag",
		"note_ids": TRIAGE_NOTE_IDS,
		"mesh_path": TRIAGE_PICKUP_MESH_PATH,
		"albedo_path": TRIAGE_PICKUP_ALBEDO_PATH,
		"albedo_size": Vector2i(1254, 1254),
		# Story identity is a surface choice, not a separate physics family.
		"albedo_by_note_id": {
			"rtv_lore_clinic_triage_card": TRIAGE_PICKUP_ALBEDO_PATH,
			"rtv_lore_triage_unknown_male": "res://rtv-lore-elements/assets/textures/triage_school_ink_v001.png",
		},
		"material_tint": Color(0.88, 0.88, 0.88, 1.0),
		"world_scale": 1.0,
		"minimum_dimensions": Vector3(0.074, 0.001, 0.118),
		"maximum_dimensions": Vector3(0.078, 0.0015, 0.122),
		"stabilize_drops": true,
	},
	"folded_document": {
		"display_name": "folded document",
		"note_ids": FOLDED_NOTE_IDS,
		"mesh_path": "res://rtv-lore-elements/assets/models/folded_document_split_uv_v001.tres",
		"albedo_path": "res://rtv-lore-elements/assets/textures/folded_border_albedo_v001.png",
		"albedo_size": Vector2i(1086, 1448),
		"albedo_by_note_id": {
			"rtv_lore_border_shift_log": "res://rtv-lore-elements/assets/textures/folded_border_albedo_v001.png",
			"rtv_lore_radio_transcript": "res://rtv-lore-elements/assets/textures/folded_radio_albedo_v001.png",
			"rtv_lore_last_letter_leena": "res://rtv-lore-elements/assets/textures/folded_leena_albedo_v001.png",
			"rtv_lore_letter_tampere": "res://rtv-lore-elements/assets/textures/folded_tampere_albedo_v001.png",
		},
		"material_tint": Color(0.70, 0.70, 0.70, 1.0),
		"world_scale": HAMINA_PICKUP_WORLD_SCALE,
		"minimum_dimensions": HAMINA_PICKUP_MIN_DIMENSIONS,
		"maximum_dimensions": HAMINA_PICKUP_MAX_DIMENSIONS,
		"stabilize_drops": true,
	},
	# RTV37 notebook family: collision is derived from accepted mesh bounds.
	"torn_notebook": {
		"display_name": "torn notebook page",
		"note_ids": ["rtv_lore_forest_cache_note", "rtv_lore_weathered_recipe", "rtv_lore_guard_three_lines"],
		"mesh_path": "res://rtv-lore-elements/assets/models/torn_notebook_blender_mesh.tres",
		"albedo_path": "res://rtv-lore-elements/assets/textures/torn_notebook_albedo.png",
		"albedo_size": Vector2i(1254, 1254),
		"material_tint": Color(0.82, 0.82, 0.82, 1.0),
		"world_scale": 1.0,
		"minimum_dimensions": Vector3(0.134, 0.002, 0.189),
		"maximum_dimensions": Vector3(0.136, 0.004, 0.191),
		"stabilize_drops": true,
	},
	# End RTV37 notebook family.
	"crayon_map": {
		"display_name": "handled crayon map",
		"note_ids": ["rtv_lore_child_kitchen_map"],
		"mesh_path": "res://rtv-lore-elements/assets/models/crayon_map_v001.tres",
		"albedo_path": "res://rtv-lore-elements/assets/textures/crayon_map_albedo_v001.png",
		"albedo_size": Vector2i(1448, 1086),
		"material_tint": Color(0.86, 0.86, 0.86, 1.0),
		"world_scale": 1.0,
		# Bounds include reopened folds, not inflated paper stock thickness.
		"minimum_dimensions": Vector3(0.199, 0.0108, 0.299),
		"maximum_dimensions": Vector3(0.201, 0.0111, 0.301),
		"angular_damp": 4.0,
		"stabilize_drops": true,
	},
	"report_sheet": {
		"display_name": "full-size report sheet",
		"note_ids": ["rtv_lore_evacuation_notice", "rtv_lore_patrol_warning", "rtv_lore_schoolroom_list", "rtv_lore_smuggler_ledger"],
		"mesh_path": "res://rtv-lore-elements/assets/models/sheet_evacuation_v001.tres",
		"albedo_path": "res://rtv-lore-elements/assets/textures/sheet_evacuation_v001.png",
		"albedo_size": Vector2i(1448, 1086),
		"albedo_by_note_id": {
			"rtv_lore_evacuation_notice": "res://rtv-lore-elements/assets/textures/sheet_evacuation_v001.png",
			"rtv_lore_patrol_warning": "res://rtv-lore-elements/assets/textures/sheet_patrol-warning_v001.png",
			"rtv_lore_schoolroom_list": "res://rtv-lore-elements/assets/textures/sheet_schoolroom-list_v001.png",
			"rtv_lore_smuggler_ledger": "res://rtv-lore-elements/assets/textures/sheet_smuggler-ledger_v001.png",
		},
		"material_tint": Color(0.86, 0.86, 0.86, 1.0),
		"world_scale": 1.0,
		"minimum_dimensions": Vector3(0.199, 0.0035, 0.299),
		"maximum_dimensions": Vector3(0.201, 0.0037, 0.301),
		"angular_damp": 4.0,
		"stabilize_drops": true,
	},
	"report_sheet_rail": {
		"display_name": "torn rail manifest sheet",
		"note_ids": ["rtv_lore_rail_manifest"],
		"mesh_path": "res://rtv-lore-elements/assets/models/sheet_rail-manifest_v001.tres",
		"albedo_path": "res://rtv-lore-elements/assets/textures/sheet_rail-manifest_v001.png",
		"albedo_size": Vector2i(1448, 1086),
		"material_tint": Color(0.86, 0.86, 0.86, 1.0),
		"world_scale": 1.0,
		"minimum_dimensions": Vector3(0.199, 0.0033, 0.292),
		"maximum_dimensions": Vector3(0.201, 0.0036, 0.295),
		"angular_damp": 4.0,
		"stabilize_drops": true,
	},
	"report_sheet_orders": {
		"display_name": "layered posted orders",
		"note_ids": ["rtv_lore_posted_orders_layered"],
		"mesh_path": "res://rtv-lore-elements/assets/models/sheet_posted-orders_v001.tres",
		"albedo_path": "res://rtv-lore-elements/assets/textures/sheet_posted-orders-07_v001.png",
		"albedo_size": Vector2i(1448, 1086),
		# Explicit layer order matches the reviewed two-surface export. Factors
		# are linear stock colors, independent of the sRGB family exposure tint.
		"material_layers": [
			{"albedo_path": "res://rtv-lore-elements/assets/textures/sheet_posted-orders-07_v001.png", "stock_factor": 0.86},
			{"albedo_path": "res://rtv-lore-elements/assets/textures/sheet_posted-orders-11_v001.png", "stock_factor": 1.0},
		],
		"material_tint": Color(0.86, 0.86, 0.86, 1.0),
		"world_scale": 1.0,
		"minimum_dimensions": Vector3(0.199, 0.0039, 0.299),
		"maximum_dimensions": Vector3(0.201, 0.0042, 0.301),
		"angular_damp": 4.0,
		"stabilize_drops": true,
	},
}
const HAMINA_DROP_GUARD_FRAMES := 360
const HAMINA_DROP_GUARD_CLEARANCE := 0.001
const HAMINA_DROP_GUARD_RECOVERY_HEIGHT := 0.035
const WORLD_PICKUP_PENETRATION_TOLERANCE := 0.006
const WORLD_PICKUP_REST_TOLERANCE := 0.0001
const WORLD_PICKUP_REST_CLEARANCE := 0.00015
const WORLD_PICKUP_REST_MAX_LOWERING := 0.006
const HAMINA_DROP_GUARD_MIN_NORMAL_Y := 0.45
# Wall-only safety net: do not inflate paper or change furniture-edge support.
const WORLD_PICKUP_WALL_CLEARANCE := 0.001
const WORLD_PICKUP_WALL_CONTACT_TOLERANCE := 0.002
const WORLD_PICKUP_WALL_RELEASE_REACH := 0.035
const WORLD_PICKUP_WALL_TOP_CLEARANCE := 0.02
const WORLD_PICKUP_WALL_MAX_NORMAL_Y := 0.2
const JOURNAL_DATA_PATH := "user://lore-elements-journal.cfg"
const JOURNAL_INPUT_ACTION := "rtv_lore_open_journal"
const READER_FONT_PATH := "res://rtv-lore-elements/assets/fonts/Caveat-Regular.ttf"
const READER_PRINT_FONT_PATH := "res://rtv-lore-elements/assets/fonts/NothingYouCouldDo.ttf"
const READER_PRESENTATION := preload("res://rtv-lore-elements/ReaderPresentation.gd")
const READER_INK := preload("res://rtv-lore-elements/ReaderInk.gd")
const VOICEOVER_AUDIO_PATH_PREFIX := "res://rtv-lore-elements/assets/audio/voiceover/"
const VOICEOVER_AUDIO_BUS := "SFX"
const NOTE_LOOT_TABLE := "LT_Master"
const MCM_HELPERS_PATH := "res://ModConfigurationMenu/Scripts/Doink Oink/MCM_Helpers.tres"
const MCM_MOD_ID := "rtv_lore_elements"
const MCM_CONFIG_DIR := "user://MCM/rtv_lore_elements"
const MCM_CONFIG_FILE := MCM_CONFIG_DIR + "/config.ini"
const MCM_SPAWN_MULTIPLIER_KEY := "lore_note_spawn_multiplier"
const MCM_JOURNAL_HOTKEY_KEY := "lore_journal_hotkey"
const MAP_PIN_LAYER_NAME := "RtvLorePinLayer"
const MAP_PIN_MARKER_NAME_PREFIX := "RtvLorePin_"
const MAP_PIN_BASE_ZOOM := 0.75
const DEFAULT_LORE_NOTE_SPAWN_MULTIPLIER := 1.0
const MAX_LORE_NOTE_SPAWN_MULTIPLIER := 20.0
const DEFAULT_JOURNAL_HOTKEY := KEY_J
const DEFAULT_JOURNAL_HOTKEY_TYPE := "Key"
const DEFAULT_NOTE_TYPE := "notice"
const FALLBACK_NOTE_TYPE_STYLES := {
	"notice": {
		"paper_color": "#d8cca7",
		"border_color": "#5b472d",
		"ink_color": "#2b261d",
		"accent_color": "#b44c2a",
		"body_font": "handwritten",
		"body_font_size": 25,
		"title_font_size": 24,
		"canvas_size": [680, 500],
		"margins": {"left": 38, "top": 30, "right": 38, "bottom": 28},
		"rotation_degrees": -0.8,
		"decoration": "notice",
		"stamp_key": "reader.stamp.notice"
	}
}
const LEGACY_HELLO_NOTE_ID := "rtv_lore_hello_note"
const LEGACY_HELLO_NOTE := {
	"id": LEGACY_HELLO_NOTE_ID,
	"name": "Damaged Field Note",
	"note_type": "notice",
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

# Restore-only bookkeeping. Never serialize or rewrite a save from these hooks.
var _world_pickup_restore_enabled := false
var _world_pickup_restore_pending := false
var _world_pickup_before_restore := {}
var AUDIO_INSTANCE_2D_SCENE = preload("res://Resources/AudioInstance2D.tscn")

var _lib = null
var _use_hook_id := -1
var _context_use_hook_id := -1
var _ui_manager_input_hook_id := -1
var _auto_place_hook_id := -1
var _lootcontainer_fill_buckets_hook_id := -1
var _lootsimulation_fill_buckets_hook_id := -1
var _interface_map_hook_id := -1

var _notes := {}
var _note_type_styles := {}
var _note_type_warning_ids := {}
var _ui_strings := {}
var _ui_string_warning_keys := {}
var _reader_font = null
var _reader_print_font = null
var _reader_mono_font = null
var _reader_paper_textures: Dictionary = {}
var _mcm_helpers = null
var _world_pickup_variants := {}
var _world_pickup_variant_by_note_id := {}
var _hamina_pickup_mesh: ArrayMesh = null
var _hamina_pickup_material: ShaderMaterial = null
var _registered_voiceover_ids := {}
var _voiceover_warning_ids := {}
var _pin_warning_ids := {}
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
var _modal_previous_occupied := false

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
var _active_voiceover_player: Node = null
var _hamina_pickup_stabilization_logged := false
var _hamina_drop_guard_correction_logged := false
var _hamina_guarded_pickup_ids := {}
var _world_pickup_stabilization_logged := {}
var _world_pickup_guard_correction_logged := {}
var _world_pickup_guarded_ids := {}
var _world_pickup_guard_generation := 0
var _world_pickup_placement_ids := {}
var _world_pickup_context_starts := {}
var _world_pickup_collision_ids := {}
var _world_pickup_upright_enabled := false
var _world_pickup_orientation_inputs := {}
var _notebook_portrait_enabled := false
var _folded_compact_enabled := false

func _process(_delta: float) -> void:
	_update_map_pin_screen_positions()

func _ready() -> void:
	set_process(false)
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
	_load_ui_strings()
	_load_note_type_styles()
	_load_reader_font()
	if _reader_font == null:
		push_warning("[rtv_lore_elements] Caveat font unavailable; reader will use the default UI font.")
	_load_world_pickup_assets()
	_register_read_hooks()
	_register_ui_manager_input_hook()
	_register_discovery_hooks()
	_register_journal_input()
	_register_mcm_config()
	_register_loot_multiplier_hooks()
	_register_map_pin_hooks()
	_register_world_pickup_release_hooks()
	_register_world_pickup_restore_hooks()
	_register_world_pickup_monitor()
	_register_notebook_inventory_hooks()
	_register_folded_inventory_hooks()
	_register_lore_content()
	_load_journal()

func _load_reader_font() -> void:
	var font := FontFile.new()
	var error := font.load_dynamic_font(READER_FONT_PATH)
	if error == OK:
		_reader_font = READER_INK.pen_font(font)
	else:
		push_warning("[rtv_lore_elements] Caveat font load failed: " + str(error))

	var mono_font := SystemFont.new()
	mono_font.font_names = PackedStringArray(["Consolas", "Courier New", "DejaVu Sans Mono", "monospace"])
	_reader_mono_font = mono_font
	var print_font := FontFile.new()
	if FileAccess.file_exists(READER_PRINT_FONT_PATH) && print_font.load_dynamic_font(READER_PRINT_FONT_PATH) == OK:
		if _reader_font != null: print_font.fallbacks = [_reader_font]
		_reader_print_font = print_font
	else:
		_reader_print_font = _reader_font

func _load_world_pickup_assets() -> void:
	_world_pickup_variants = {}
	_world_pickup_variant_by_note_id = {}
	_hamina_pickup_mesh = null
	_hamina_pickup_material = null

	var shader_resource = ResourceLoader.load(
		WORLD_ITEM_SHADER_PATH,
		"Shader",
		ResourceLoader.CACHE_MODE_REUSE
	)
	if !(shader_resource is Shader):
		push_warning(
			"[rtv_lore_elements] vanilla world-item shader unavailable; "
			+ "using shared note pickups."
		)
		return

	for variant_id in WORLD_PICKUP_VARIANT_DEFINITIONS:
		_load_world_pickup_variant(
			str(variant_id),
			WORLD_PICKUP_VARIANT_DEFINITIONS[variant_id],
			shader_resource as Shader
		)

	var hamina_variant: Dictionary = _world_pickup_variants.get(
		"hamina_dispatch",
		{}
	)
	_hamina_pickup_mesh = hamina_variant.get("mesh") as ArrayMesh
	_hamina_pickup_material = hamina_variant.get("material") as ShaderMaterial

func _load_world_pickup_variant(
	variant_id: String,
	definition: Dictionary,
	shader: Shader
) -> void:
	var display_name := str(definition.get("display_name", variant_id))
	var mesh_path := str(definition.get("mesh_path", ""))
	var mesh_resource = ResourceLoader.load(
		mesh_path,
		"ArrayMesh",
		ResourceLoader.CACHE_MODE_IGNORE
	)
	if !(mesh_resource is ArrayMesh):
		_warn_world_pickup_fallback(display_name, "mesh unavailable")
		return

	var pickup_mesh := mesh_resource as ArrayMesh
	var material_layers: Array = definition.get("material_layers", [])
	var expected_surfaces := material_layers.size() if !material_layers.is_empty() else 1
	if pickup_mesh.get_surface_count() != expected_surfaces:
		_warn_world_pickup_fallback(display_name, "mesh surface count must match its explicit material layers")
		return

	var mesh_dimensions := pickup_mesh.get_aabb().size
	var minimum_dimensions: Vector3 = definition.get(
		"minimum_dimensions",
		Vector3.ZERO
	)
	var maximum_dimensions: Vector3 = definition.get(
		"maximum_dimensions",
		Vector3(INF, INF, INF)
	)
	if !_dimensions_in_range(
		mesh_dimensions,
		minimum_dimensions,
		maximum_dimensions
	):
		_warn_world_pickup_fallback(
			display_name,
			"mesh dimensions are invalid: " + str(mesh_dimensions)
		)
		return

	var albedo_path := str(definition.get("albedo_path", ""))
	var expected_albedo_size: Vector2i = definition.get(
		"albedo_size",
		Vector2i(512, 512)
	)
	var albedo_image := _load_world_pickup_albedo(albedo_path, expected_albedo_size, display_name)
	if albedo_image == null:
		return

	var material_tint: Color = definition.get("material_tint", Color.WHITE)
	var pickup_material := _build_world_pickup_material(
		variant_id,
		shader,
		albedo_image,
		material_tint
	)
	var materials_by_note_id := {}
	var surface_paths: Dictionary = definition.get("albedo_by_note_id", {})
	var note_ids: Array = definition.get("note_ids", [])
	var layer_materials: Array[ShaderMaterial] = []
	if !material_layers.is_empty():
		# Mixed per-story/per-layer mapping is intentionally unsupported. Fail
		# atomically rather than silently dropping a layer or showing wrong ink.
		if !surface_paths.is_empty():
			_warn_world_pickup_fallback(display_name, "layer and per-note mappings cannot be combined")
			return
		for layer in material_layers:
			if !(layer is Dictionary) || !layer.has("albedo_path"):
				_warn_world_pickup_fallback(display_name, "invalid layer material definition")
				return
			var factor := float(layer.get("stock_factor", 1.0))
			if !is_finite(factor) || factor <= 0.0 || factor > 1.0:
				_warn_world_pickup_fallback(display_name, "invalid linear stock factor")
				return
			var layer_image := _load_world_pickup_albedo(str(layer.albedo_path), expected_albedo_size, display_name)
			if layer_image == null:
				return
			var layer_tint := Color(factor, factor, factor, 1.0).linear_to_srgb() * material_tint
			layer_materials.append(_build_world_pickup_material(
				variant_id + "_layer_" + str(layer_materials.size()), shader, layer_image, layer_tint
			))
	if !surface_paths.is_empty():
		# Fail the family atomically rather than show another patient's record.
		if surface_paths.size() != note_ids.size():
			_warn_world_pickup_fallback(display_name, "surface mapping must cover every note")
			return
		for note_id in note_ids:
			if !surface_paths.has(note_id):
				_warn_world_pickup_fallback(display_name, "surface missing for " + str(note_id))
				return
			var surface_path := str(surface_paths[note_id])
			if surface_path == albedo_path:
				materials_by_note_id[note_id] = pickup_material
				continue
			var surface_image := _load_world_pickup_albedo(surface_path, expected_albedo_size, display_name)
			if surface_image == null:
				return
			materials_by_note_id[note_id] = _build_world_pickup_material(
				variant_id + "_" + str(note_id), shader, surface_image, material_tint
			)
	var runtime_variant := definition.duplicate(true)
	runtime_variant["id"] = variant_id
	runtime_variant["mesh"] = pickup_mesh
	runtime_variant["material"] = pickup_material
	runtime_variant["materials_by_note_id"] = materials_by_note_id
	runtime_variant["layer_materials"] = layer_materials
	# Retain the accepted thin symmetric proxy and its natural edge tipping.
	# Presentation compensates for the solver's overlap allowance independently.
	var world_dimensions := mesh_dimensions * float(definition.get("world_scale", 1.0))
	runtime_variant["collision_size"] = Vector3(
		world_dimensions.x + 0.004, maxf(world_dimensions.y + 0.002, 0.006), world_dimensions.z + 0.004
	)
	runtime_variant["collision_position"] = Vector3(0.0, world_dimensions.y * 0.5, 0.0)
	var rest_offsets := PackedVector3Array()
	var hull := pickup_mesh.create_convex_shape(true, false)
	if hull == null || hull.points.is_empty():
		_warn_world_pickup_fallback(display_name, "visual contact hull unavailable")
		return
	var mesh_center := pickup_mesh.get_aabb().get_center()
	var mesh_min_y := pickup_mesh.get_aabb().position.y
	var rest_scale := float(definition.get("world_scale", 1.0))
	for point in hull.points:
		rest_offsets.append((point - Vector3(mesh_center.x, mesh_min_y, mesh_center.z)) * rest_scale)
	runtime_variant["rest_offsets"] = rest_offsets
	var contact_query := ConvexPolygonShape3D.new()
	var query_points := PackedVector3Array()
	for point in rest_offsets:
		query_points.append(point + Vector3.UP * HAMINA_DROP_GUARD_RECOVERY_HEIGHT)
		query_points.append(point - Vector3.UP * HAMINA_DROP_GUARD_RECOVERY_HEIGHT)
	contact_query.points = query_points
	contact_query.margin = 0.0
	runtime_variant["contact_query"] = contact_query
	var contact_faces := pickup_mesh.get_faces()
	for index in range(contact_faces.size()):
		contact_faces[index] = (contact_faces[index] - Vector3(mesh_center.x, mesh_min_y, mesh_center.z)) * rest_scale
	runtime_variant["contact_faces"] = contact_faces
	runtime_variant["contact_bounds"] = AABB(Vector3(-world_dimensions.x * 0.5, 0.0, -world_dimensions.z * 0.5), world_dimensions)
	var contact_groups := {}
	for index in range(0, contact_faces.size(), 3):
		var center := (contact_faces[index]+contact_faces[index+1]+contact_faces[index+2])/3.0
		var cell := Vector2i(floori(center.x/world_dimensions.x*8.0), floori(center.z/world_dimensions.z*8.0))
		if !contact_groups.has(cell):
			contact_groups[cell] = {"bounds":AABB(contact_faces[index],Vector3.ZERO), "indices":[]}
		var group: Dictionary = contact_groups[cell]
		group.indices.append(index)
		for corner in range(3): group.bounds = (group.bounds as AABB).expand(contact_faces[index+corner])
	runtime_variant["contact_groups"] = contact_groups.values()
	_world_pickup_variants[variant_id] = runtime_variant
	for note_id in definition.get("note_ids", []):
		_world_pickup_variant_by_note_id[str(note_id)] = variant_id

	var world_scale := float(definition.get("world_scale", 1.0))
	print(
		"[rtv_lore_elements] loaded "
		+ display_name
		+ " pickup: raw="
		+ str(mesh_dimensions)
		+ ", world="
		+ str(mesh_dimensions * world_scale)
		+ ", collision="
		+ str(runtime_variant["collision_size"])
	)

func _load_world_pickup_albedo(path: String, expected_size: Vector2i, display_name: String) -> Image:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_warn_world_pickup_fallback(display_name, "albedo unavailable")
		return null
	var image := Image.new()
	if image.load_png_from_buffer(file.get_buffer(file.get_length())) != OK || image.is_empty():
		_warn_world_pickup_fallback(display_name, "albedo could not be decoded")
		return null
	if image.get_size() != expected_size:
		_warn_world_pickup_fallback(display_name, "albedo must be " + str(expected_size))
		return null
	if !image.has_mipmaps() && image.generate_mipmaps() != OK:
		_warn_world_pickup_fallback(display_name, "albedo mipmaps failed")
		return null
	return image

func _build_world_pickup_material(
	variant_id: String,
	shader: Shader,
	albedo_image: Image,
	material_tint: Color = Color.WHITE
) -> ShaderMaterial:
	var pickup_material := ShaderMaterial.new()
	pickup_material.resource_name = "RTV_" + variant_id.to_pascal_case() + "_PickupMaterial"
	pickup_material.shader = shader
	pickup_material.set_shader_parameter(
		"albedo",
		ImageTexture.create_from_image(albedo_image)
	)
	pickup_material.set_shader_parameter("normal", null)
	pickup_material.set_shader_parameter("tint", material_tint)
	pickup_material.set_shader_parameter("limiter", 0.1)
	pickup_material.set_shader_parameter("dynamic", false)
	pickup_material.set_shader_parameter("fractional", false)
	pickup_material.set_shader_parameter("enableRain", false)
	pickup_material.set_shader_parameter("enableSnow", false)
	pickup_material.set_shader_parameter("snowTop", 0.0)
	pickup_material.set_shader_parameter("snowSide", 0.0)
	pickup_material.set_shader_parameter("snowBottom", 0.0)
	pickup_material.set_shader_parameter("occlusion", false)
	pickup_material.set_shader_parameter("noise", false)
	pickup_material.set_shader_parameter("metal", false)
	pickup_material.set_shader_parameter("glow", false)
	pickup_material.set_shader_parameter("viewmodel", false)
	pickup_material.set_shader_parameter("fresnel", 0.5)
	return pickup_material

func _warn_world_pickup_fallback(display_name: String, reason: String) -> void:
	push_warning(
		"[rtv_lore_elements] "
		+ display_name
		+ " pickup "
		+ reason
		+ "; using the shared note pickup."
	)

func _dimensions_in_range(
	dimensions: Vector3,
	minimum: Vector3,
	maximum: Vector3
) -> bool:
	return (
		dimensions.x >= minimum.x
		&& dimensions.y >= minimum.y
		&& dimensions.z >= minimum.z
		&& dimensions.x <= maximum.x
		&& dimensions.y <= maximum.y
		&& dimensions.z <= maximum.z
	)

func _load_ui_strings() -> void:
	_ui_strings = {}
	if !FileAccess.file_exists(UI_STRINGS_PATH):
		push_warning("[rtv_lore_elements] missing UI strings file: " + UI_STRINGS_PATH)
		return

	var file := FileAccess.open(UI_STRINGS_PATH, FileAccess.READ)
	if file == null:
		push_warning("[rtv_lore_elements] failed to open UI strings file: " + UI_STRINGS_PATH)
		return

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("[rtv_lore_elements] UI strings file must contain a JSON object.")
		return

	var translation := Translation.new()
	translation.locale = UI_STRINGS_LOCALE
	for raw_key in parsed.keys():
		var key := str(raw_key)
		var value := str(parsed[raw_key])
		_ui_strings[key] = value
		translation.add_message(key, value)

	TranslationServer.add_translation(translation)

func _load_note_type_styles() -> void:
	_note_type_styles = FALLBACK_NOTE_TYPE_STYLES.duplicate(true)
	if !FileAccess.file_exists(NOTE_TYPE_DATA_PATH):
		_warn_note_type_once("missing_styles", "missing note type style file: " + NOTE_TYPE_DATA_PATH)
		return

	var file := FileAccess.open(NOTE_TYPE_DATA_PATH, FileAccess.READ)
	if file == null:
		_warn_note_type_once("open_styles", "failed to open note type style file: " + NOTE_TYPE_DATA_PATH)
		return

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		_warn_note_type_once("style_root", "note type style file must contain a JSON object.")
		return

	for raw_type in parsed.keys():
		var note_type := str(raw_type).strip_edges()
		if note_type.is_empty():
			_warn_note_type_once("empty_style_type", "skipping note type style with empty key.")
			continue

		var raw_style = parsed[raw_type]
		if typeof(raw_style) != TYPE_DICTIONARY:
			_warn_note_type_once(note_type + ":style_type", "skipping malformed note type style: " + note_type)
			continue

		var fallback: Dictionary = _note_type_styles.get(DEFAULT_NOTE_TYPE, {}).duplicate(true)
		if _note_type_styles.has(note_type):
			fallback = _note_type_styles[note_type].duplicate(true)
		for key in raw_style.keys():
			fallback[key] = raw_style[key]
		_note_type_styles[note_type] = fallback

	if !_note_type_styles.has(DEFAULT_NOTE_TYPE):
		_note_type_styles[DEFAULT_NOTE_TYPE] = FALLBACK_NOTE_TYPE_STYLES[DEFAULT_NOTE_TYPE].duplicate(true)

func _warn_note_type_once(warning_id: String, message: String) -> void:
	if _note_type_warning_ids.has(warning_id):
		return
	_note_type_warning_ids[warning_id] = true
	push_warning("[rtv_lore_elements] " + message)

func _ui_text(key: String, fallback := "") -> String:
	var translated := TranslationServer.translate(key)
	if translated != key:
		return translated
	if _ui_strings.has(key):
		return str(_ui_strings[key])
	if !fallback.is_empty():
		return fallback
	if !_ui_string_warning_keys.has(key):
		_ui_string_warning_keys[key] = true
		push_warning("[rtv_lore_elements] missing UI string: " + key)
	return key

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

func _register_map_pin_hooks() -> void:
	_interface_map_hook_id = _lib.hook("interface-map-post", _on_interface_map_post, 40)
	if _interface_map_hook_id != -1:
		print("[rtv_lore_elements] registered interface-map-post pin refresh hook.")
	else:
		push_warning("[rtv_lore_elements] interface-map-post hook unavailable; map pins will refresh through node discovery and journal events.")

	var node_added_callback := Callable(self, "_on_tree_node_added_for_pins")
	if !get_tree().node_added.is_connected(node_added_callback):
		get_tree().node_added.connect(node_added_callback)

func _register_world_pickup_release_hooks() -> void:
	# Unfreeze awaits a timer: a post-hook would arrive a second too late, and
	# Metro suppresses overlapping calls to that coroutine. Observe the native
	# Placer exits instead, after its immediate Unfreeze writes disable CCD.
	var physics_pre: int = _lib.hook("placer-_physics_process-pre", _on_placer_physics_pre, 40)
	var physics_post: int = _lib.hook("placer-_physics_process-post", _on_placer_physics_post, 40)
	_lib.hook("placer-collided-pre", _on_placer_collided_pre, 40)
	_lib.hook("placer-collided-post", _on_placer_collided_post, 40)
	_lib.hook("placer-contextplace-pre", _on_placer_context_pre, 40)
	_lib.hook("placer-contextplace-post", _on_placer_context_post, 40)
	var input_pre: int = _lib.hook("placer-_input-pre", _on_placer_input_pre, 40)
	var input_post: int = _lib.hook("placer-_input-post", _on_placer_input_post, 40)
	_world_pickup_upright_enabled = physics_pre != -1 && physics_post != -1 && input_pre != -1 && input_post != -1
	if !_world_pickup_upright_enabled:
		push_warning("[rtv_lore_elements] upright placement hooks unavailable; retaining native orientation cycle.")

func _register_notebook_inventory_hooks() -> void:
	# Keep old resource paths landscape for existing external save references.
	# Convert only at the UI load/create boundary; never rewrite save scripts.
	var load_hook: int = _lib.hook("interface-loadgriditem-pre", _on_notebook_load_grid_pre, 40)
	var create_hook: int = _lib.hook("interface-create-pre", _on_notebook_create_pre, 40)
	_notebook_portrait_enabled = load_hook != -1 && create_hook != -1
	if !_notebook_portrait_enabled:
		push_warning("[rtv_lore_elements] notebook portrait hooks unavailable; retaining legacy inventory orientation.")

func _register_world_pickup_restore_hooks() -> void:
	var before: int = _lib.hook("loader-loadshelter-pre", _on_world_pickup_restore_pre, 40)
	var after: int = _lib.hook("loader-loadshelter-post", _on_world_pickup_restore_post, 40)
	_world_pickup_restore_enabled = before != -1 && after != -1
	if !_world_pickup_restore_enabled:
		push_warning("[rtv_lore_elements] shelter restore hooks unavailable; saved pickup poses remain unchanged.")

func _on_world_pickup_restore_pre(_target_shelter) -> void:
	_world_pickup_before_restore.clear()
	_world_pickup_restore_pending = _world_pickup_restore_enabled
	if !_world_pickup_restore_enabled:
		return
	for body in get_tree().get_nodes_in_group("Item"):
		_world_pickup_before_restore[body.get_instance_id()] = true

func _on_world_pickup_restore_post(_target_shelter) -> void:
	if !_world_pickup_restore_enabled || !_world_pickup_restore_pending:
		return
	_world_pickup_restore_pending = false
	var candidates := []
	for node in get_tree().get_nodes_in_group("Item"):
		if _world_pickup_before_restore.has(node.get_instance_id()) || !(node is RigidBody3D):
			continue
		var body := node as RigidBody3D
		if !body.freeze || _get_world_pickup_variant_for_body(body).is_empty():
			continue
		candidates.append({"body": weakref(body), "pose": body.global_transform})
	_world_pickup_before_restore.clear()
	if !candidates.is_empty():
		_correct_world_pickup_restored_contacts(candidates)

func _correct_world_pickup_restored_contacts(candidates: Array) -> void:
	# Native LoadShelter creates furniture, restores the pose, then Freeze()s
	# pickups. Drop/sleep guards intentionally skip these bodies. Give freshly
	# restored colliders one physics frame before the bounded restore repairs.
	await get_tree().physics_frame
	# Legacy patient-report saves used an upright XY mesh with a bottom-edge
	# origin. Custom papers use XZ and a centered origin. Only repair physically
	# invalid, supported legacy-like poses; unmarked saves can also be modern.
	candidates.sort_custom(func(a, b): return a.pose.origin.y < b.pose.origin.y)
	var legacy_repairs := []
	var restored_rids: Array[RID] = []
	for candidate in candidates:
		var restored = candidate.body.get_ref()
		if !is_instance_valid(restored) || !restored.is_inside_tree() || !restored.freeze || restored.gravity_scale <= 0.0:
			continue
		if !restored.global_transform.is_finite() || !restored.global_transform.is_equal_approx(candidate.pose):
			continue
		var variant := _get_world_pickup_variant_for_body(restored)
		if !variant.is_empty() && absf(restored.global_basis.z.y) >= 0.55 && _world_pickup_legacy_support_gap(restored, restored.global_transform, variant.rest_offsets) < -0.015:
			# Only deeply invalid legacy-like bodies may be ignored while their
			# poses are rebuilt. Keep valid/moved/held modern papers as obstacles.
			restored_rids.append(restored.get_rid())
	for candidate in candidates:
		var body = candidate.body.get_ref()
		if !is_instance_valid(body) || !body.is_inside_tree() || !body.freeze || body.gravity_scale <= 0.0:
			continue
		if !body.global_transform.is_finite() || !body.global_transform.is_equal_approx(candidate.pose):
			continue
		var variant := _get_world_pickup_variant_for_body(body)
		if variant.is_empty() || variant.get("stabilize_drops", false) != true:
			continue
		var legacy := _world_pickup_legacy_restored_pose(body, variant, legacy_repairs, restored_rids)
		if !legacy.is_empty():
			body.global_transform = legacy.pose
			legacy_repairs.append(legacy)
			continue
		var lift := _world_pickup_contact_lift(body, variant)
		# Upward-only, <= 10 mm: do not lower intentional placements, wake a
		# frozen save, flatten folds, relocate lost items or change release spin.
		if is_finite(lift) && lift > WORLD_PICKUP_REST_TOLERANCE && lift <= 0.01:
			body.global_position.y += lift
	if !legacy_repairs.is_empty():
		print("[rtv_lore_elements] repaired ", legacy_repairs.size(), " legacy placed-note poses; native checkpoint will retain them.")

func _world_pickup_legacy_support_gap(body: RigidBody3D, pose: Transform3D, points: PackedVector3Array) -> float:
	var gap := INF
	var space := body.get_world_3d().direct_space_state
	for offset in points:
		var point := pose * offset
		var query := PhysicsRayQueryParameters3D.create(
			point + Vector3.UP * 0.18, point - Vector3.UP * 0.15,
			body.collision_mask & ~4, [body.get_rid()])
		var hit := space.intersect_ray(query)
		if hit.is_empty() || !(hit.get("collider") is StaticBody3D) || hit.normal.y < 0.95:
			continue
		gap = minf(gap, point.y - hit.position.y)
	return gap

func _world_pickup_legacy_restored_pose(body: RigidBody3D, variant: Dictionary, repairs: Array, excluded: Array[RID]) -> Dictionary:
	var old := body.global_transform
	# Near-edge-on old interpretations are ambiguous. Never guess at displays.
	if absf(old.basis.z.y) < 0.55 || !old.basis.is_equal_approx(old.basis.orthonormalized()):
		return {}
	var bounds: AABB = variant.contact_bounds
	var center := bounds.get_center()
	# Native MS_Patient_Report bounds: 200 x 300 x 8 mm, bottom-edge origin.
	var legacy_center := old * Vector3(0.0, 0.15, 0.0)
	var pose := Transform3D(old.basis * Basis(Vector3.RIGHT, PI * 0.5), Vector3.ZERO)
	pose.origin = legacy_center - pose.basis * center
	var points: PackedVector3Array = variant.rest_offsets
	var current_gap := _world_pickup_legacy_support_gap(body, old, points)
	var target_gap := _world_pickup_legacy_support_gap(body, pose, points)
	if !is_finite(current_gap) || !is_finite(target_gap) || target_gap < -0.01 || target_gap > 0.125:
		return {}
	var bottom := INF
	var top := -INF
	for point in points:
		var height := (pose * point).y
		bottom = minf(bottom, height)
		top = maxf(top, height)
	var stack := false
	var support_height := bottom - target_gap
	for repair in repairs:
		# Old 50 mm proxies can leave a stack floating after its base changes.
		# Admit only a connected, nearly horizontal legacy stack, never a valid
		# modern upright display (its bottom already touches its support).
		var separation: float = legacy_center.y - repair.legacy_center.y
		var local: Vector3 = repair.old.affine_inverse() * legacy_center
		var new_local: Vector3 = repair.pose.affine_inverse() * (pose * center)
		var under: AABB = repair.bounds
		if absf(old.basis.z.y) >= 0.95 && absf(repair.old.basis.z.y) >= 0.95 && separation >= 0.015 && separation <= 0.065 && absf(local.x) < 0.1 && local.y > 0.0 && local.y < 0.3 && absf(new_local.x) < under.size.x * 0.5 && absf(new_local.z) < under.size.z * 0.5:
			stack = true
			support_height = maxf(support_height, repair.top)
	if current_gap >= -0.015 && !(stack && current_gap > 0.015):
		return {}
	var adjustment := support_height - bottom + 0.001
	if absf(adjustment) > 0.125:
		return {}
	pose.origin.y += adjustment
	# Validate the whole convex visual envelope against furniture and walls,
	# not just downward rays. Valid newer papers remain collision obstacles.
	var shape := ConvexPolygonShape3D.new()
	shape.points = points
	shape.margin = 0.0
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = pose
	query.collision_mask = body.collision_mask
	var obstacles_excluded: Array[RID] = excluded.duplicate()
	if !obstacles_excluded.has(body.get_rid()):
		obstacles_excluded.append(body.get_rid())
	query.exclude = obstacles_excluded
	query.margin = 0.0
	if !body.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty():
		return {}
	return {"pose":pose, "old":old, "legacy_center":legacy_center, "bounds":bounds, "top":top + adjustment}

func _on_notebook_load_grid_pre(slot_data, _target_grid, _grid_position) -> void:
	_upgrade_notebook_slot(slot_data, true)

func _on_notebook_create_pre(slot_data, _target_grid, _use_drop) -> void:
	_upgrade_notebook_slot(slot_data, false)

func _upgrade_notebook_slot(slot_data, preserve_cells: bool) -> void:
	if !_notebook_portrait_enabled || slot_data == null || slot_data.itemData == null:
		return
	var old_item = slot_data.itemData
	if str(old_item.file) not in NOTEBOOK_NOTE_IDS || old_item.size != Vector2(2, 1):
		return
	var portrait = load(NOTEBOOK_PORTRAIT_ITEM_PREFIX + str(old_item.file) + ".tres")
	if portrait == null || portrait.size != Vector2(1, 2):
		push_warning("[rtv_lore_elements] portrait resource unavailable; preserving saved notebook footprint.")
		return
	slot_data.itemData = portrait
	if preserve_cells:
		# Old landscape false -> new portrait true (and conversely). Position,
		# occupied cells, condition and all other SlotData fields remain intact.
		slot_data.gridRotated = !slot_data.gridRotated

func _register_folded_inventory_hooks() -> void:
	# Keep legacy 2x2 external paths intact. Shrink only before native UI creates
	# occupied cells; both rotations remain subsets of the original saved square.
	var load_hook: int = _lib.hook("interface-loadgriditem-pre", _on_folded_load_grid_pre, 40)
	var create_hook: int = _lib.hook("interface-create-pre", _on_folded_create_pre, 40)
	_folded_compact_enabled = load_hook != -1 && create_hook != -1
	if !_folded_compact_enabled:
		push_warning("[rtv_lore_elements] folded inventory hooks unavailable; retaining legacy footprint and value.")

func _on_folded_load_grid_pre(slot_data, _target_grid, _grid_position) -> void:
	_upgrade_folded_slot(slot_data)

func _on_folded_create_pre(slot_data, _target_grid, _use_drop) -> void:
	_upgrade_folded_slot(slot_data)

func _upgrade_folded_slot(slot_data) -> void:
	if !_folded_compact_enabled || slot_data == null || slot_data.itemData == null:
		return
	var old_item = slot_data.itemData
	if str(old_item.file) not in FOLDED_NOTE_IDS || old_item.size != Vector2(2, 2):
		return
	var compact = load(FOLDED_COMPACT_ITEM_PREFIX + str(old_item.file) + ".tres")
	if compact == null || compact.size != Vector2(2, 1) || compact.file != old_item.file:
		push_warning("[rtv_lore_elements] folded resource unavailable; preserving saved item.")
		return
	# Keep position, rotation, condition and every other SlotData field. Either
	# orientation frees two old cells without entering any neighbor's footprint.
	slot_data.itemData = compact

func _on_placer_physics_pre(_delta: float) -> void:
	_capture_world_pickup_placement(_world_pickup_placement_ids)
	var placer = _lib._caller
	if !_world_pickup_can_orient(placer) || placer.orientationMode != 4 || placer.initialWait:
		return
	if !Input.is_action_just_pressed("place"):
		return
	# Plan without moving the held body. Apply only if this exact G invocation
	# subsequently takes the native release branch, not a contact or pickup.
	var snapshot: Dictionary = _world_pickup_placement_ids.get(placer.get_instance_id(), {})
	if snapshot.get("id", 0) != placer.placable.get_instance_id():
		return
	var supported := _world_pickup_supported_display_pose(placer.placable)
	if !supported.is_empty():
		snapshot["supported_pose"] = supported.pose

func _on_placer_physics_post(_delta: float) -> void:
	_apply_world_pickup_upright(_delta)
	_finish_world_pickup_placement(_world_pickup_placement_ids)

func _world_pickup_can_orient(placer) -> bool:
	if !_world_pickup_upright_enabled || !is_instance_valid(placer):
		return false
	var data = placer.gameData
	if data.freeze || data.isReloading || data.isInspecting || !data.isPlacing || data.decor:
		return false
	var pickup = placer.get("placable")
	if !is_instance_valid(pickup):
		return false
	return _get_world_pickup_variant_for_body(pickup).get("stabilize_drops", false) == true

func _on_placer_input_pre(event: InputEvent) -> void:
	var placer = _lib._caller
	if !is_instance_valid(placer):
		return
	var placer_id: int = placer.get_instance_id()
	_world_pickup_orientation_inputs.erase(placer_id)
	if !(event is InputEventMouseButton) || !event.pressed || event.button_index != MOUSE_BUTTON_MIDDLE:
		return
	if _world_pickup_can_orient(placer) && placer.orientationMode == 3:
		_world_pickup_orientation_inputs[placer_id] = placer.placable.get_instance_id()

func _on_placer_input_post(_event: InputEvent) -> void:
	var placer = _lib._caller
	if !is_instance_valid(placer):
		return
	var placer_id: int = placer.get_instance_id()
	var pickup_id: int = _world_pickup_orientation_inputs.get(placer_id, 0)
	_world_pickup_orientation_inputs.erase(placer_id)
	if pickup_id == 0 || !_world_pickup_can_orient(placer):
		return
	# Extend only native 3 -> 1 wrapping, for the same held authored pickup.
	# The next native click already wraps 4 -> 1; modes 1-3 stay untouched.
	if placer.placable.get_instance_id() == pickup_id && placer.orientationMode == 1:
		placer.orientationMode = 4

func _apply_world_pickup_upright(delta: float) -> void:
	var placer = _lib._caller
	if !_world_pickup_can_orient(placer) || placer.orientationMode != 4:
		return
	var pickup = placer.placable
	var snapshot: Dictionary = _world_pickup_placement_ids.get(placer.get_instance_id(), {})
	if snapshot.get("id", 0) != pickup.get_instance_id():
		return
	# Authored paper fronts are +Y and printed tops -Z: +90 pitch makes both
	# front-facing and upright. Native yaw/scroll still apply. Run BEFORE the
	# existing swept preview constraint so this turn cannot bypass an obstacle.
	pickup.global_rotation.x = lerp_angle(pickup.global_rotation.x, PI / 2.0, delta * 5.0)
	pickup.global_rotation.z = lerp_angle(pickup.global_rotation.z, 0.0, delta * 5.0)

func _world_pickup_display_ray(body: RigidBody3D, start: Vector3, end: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(start, end, body.collision_mask, [body.get_rid()])
	var hit := body.get_world_3d().direct_space_state.intersect_ray(query)
	# Moving pickups/characters are not a reliable display foundation. Static
	# scene furniture and walls work without changing their collision masks.
	if hit.is_empty() || !(hit.collider is StaticBody3D):
		return {}
	return hit

func _world_pickup_display_floor(body: RigidBody3D, pose: Transform3D, collision: CollisionShape3D) -> Dictionary:
	var half: Vector3 = (collision.shape as BoxShape3D).size * 0.5
	var height := -INF
	var lowest := INF
	var support_id := 0
	# Require support under both sides and the middle, not a single ray across
	# a shelf edge. Probe the lower edge of these flat-authored (+Z bottom) papers.
	for x in [-0.8 * half.x, 0.0, 0.8 * half.x]:
		var a := pose * (collision.position + Vector3(x, -half.y, half.z))
		var b := pose * (collision.position + Vector3(x, half.y, half.z))
		var bottom := a if a.y < b.y else b
		var hit := _world_pickup_display_ray(body, bottom + Vector3.UP * 0.003, bottom + Vector3.DOWN * 0.025)
		if hit.is_empty() || hit.normal.dot(Vector3.UP) < 0.995:
			return {}
		var id: int = hit.collider.get_instance_id()
		if support_id != 0 && id != support_id:
			return {}
		support_id = id
		height = maxf(height, hit.position.y)
		lowest = minf(lowest, hit.position.y)
	if height - lowest > 0.003:
		return {}
	return {"height": height, "id": support_id}

func _world_pickup_display_path_clear(body: RigidBody3D, collision: CollisionShape3D, start: Transform3D, target: Transform3D) -> bool:
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = collision.shape
	query.collision_mask = body.collision_mask
	query.exclude = [body.get_rid()]
	query.margin = 0.001
	var space := body.get_world_3d().direct_space_state
	query.transform = start * collision.transform
	if !space.intersect_shape(query, 1).is_empty():
		return false
	# A bounded five-degree lean gets finer angular steps than normal preview.
	# Cast each translation too, so a clear endpoint cannot jump through a lip.
	var previous := start
	for step in range(1, 33):
		var next := start.interpolate_with(target, float(step) / 32.0)
		query.transform = previous * collision.transform
		query.motion = next.origin - previous.origin
		var fractions := space.cast_motion(query)
		if fractions.size() != 2 || fractions[0] < 0.99999:
			return false
		query.motion = Vector3.ZERO
		query.transform = next * collision.transform
		if !space.intersect_shape(query, 1).is_empty():
			return false
		previous = next
	return true

func _world_pickup_supported_display_pose(body: RigidBody3D) -> Dictionary:
	# This is a one-shot placement finish, never a drop/restore correction or
	# persistent attachment. All geometry is queried before changing the body.
	var pose := body.global_transform
	var collision := body.get_node_or_null("Collision") as CollisionShape3D
	if collision == null || collision.disabled || !(collision.shape is BoxShape3D):
		return {}
	if !pose.is_finite() || !pose.basis.get_scale().is_equal_approx(Vector3.ONE) || !collision.basis.is_equal_approx(Basis.IDENTITY):
		return {}
	if (-pose.basis.z).dot(Vector3.UP) < 0.999:
		return {}
	var front := Vector3(pose.basis.y.x, 0, pose.basis.y.z).normalized()
	if front.length_squared() < 0.99:
		return {}
	var floor := _world_pickup_display_floor(body, pose, collision)
	if floor.is_empty():
		return {}
	var half: Vector3 = (collision.shape as BoxShape3D).size * 0.5
	var backing := {}
	# Three upper-back samples require an actual nearby backing across most
	# of the sheet, facing its reverse. Side walls and isolated pegs do not count.
	for x in [-0.8 * half.x, 0.0, 0.8 * half.x]:
		var point := pose * (collision.position + Vector3(x, -half.y, -half.z * 0.8))
		var hit := _world_pickup_display_ray(body, point + front * 0.003, point - front * 0.03)
		if hit.is_empty() || absf(hit.normal.y) > 0.05 || hit.normal.dot(front) < 0.985:
			return {}
		if !backing.is_empty():
			if hit.collider != backing.collider || hit.normal.dot(backing.normal) < 0.999 || absf((hit.position - backing.position).dot(backing.normal)) > 0.003:
				return {}
		backing = hit
	var lean := deg_to_rad(5.0)
	var up := Vector3.UP * cos(lean) - front * sin(lean)
	var target := Transform3D(Basis(Vector3.UP.cross(front), front * cos(lean) + Vector3.UP * sin(lean), -up), pose.origin)
	var min_height := INF
	var back_distance := INF
	for x in [-half.x, half.x]:
		for y in [-half.y, half.y]:
			for z in [-half.z, half.z]:
				var corner := target * (collision.position + Vector3(x, y, z))
				min_height = minf(min_height, corner.y)
				back_distance = minf(back_distance, (corner - backing.position).dot(backing.normal))
	# Fit just clear of the backing and base, moving a few centimetres at most.
	# This gives the thin body a real backward lean instead of vertical balance.
	target.origin += front * ((0.002 - back_distance) / front.dot(backing.normal))
	target.origin.y += float(floor.height) + 0.002 - min_height
	if target.origin.distance_to(pose.origin) > 0.045:
		return {}
	var final_floor := _world_pickup_display_floor(body, target, collision)
	if final_floor.is_empty() || final_floor.id != floor.id || absf(final_floor.height - floor.height) > 0.001:
		return {}
	if !_world_pickup_display_path_clear(body, collision, pose, target):
		return {}
	return {"pose": target}

func _on_placer_collided_pre(_body: Node3D) -> void:
	_capture_world_pickup_placement(_world_pickup_collision_ids)

func _on_placer_collided_post(_body: Node3D) -> void:
	_finish_world_pickup_placement(_world_pickup_collision_ids)

func _on_placer_context_pre(target: Node3D) -> void:
	var placer = _lib._caller
	if !is_instance_valid(placer) || !(placer.get_parent() is Node3D):
		return
	_world_pickup_context_starts.erase(placer.get_instance_id())
	if _get_world_pickup_variant_for_body(target).is_empty() || placer.gameData.decor:
		return
	# Inventory instances can start at the world origin, not at the player.
	# Native ContextPlace teleports them one metre ahead before its wait. Keep
	# the viewpoint as the source side for the sweep when that wait completes.
	_world_pickup_context_starts[placer.get_instance_id()] = {
		"id": target.get_instance_id(), "origin": (placer.get_parent() as Node3D).global_position,
	}

func _on_placer_context_post(_target: Node3D) -> void:
	var placer = _lib._caller
	if !is_instance_valid(placer):
		return
	var snapshot: Dictionary = _world_pickup_context_starts.get(placer.get_instance_id(), {})
	_world_pickup_context_starts.erase(placer.get_instance_id())
	var body = instance_from_id(int(snapshot.get("id", 0)))
	if !(body is RigidBody3D) || placer.get("placable") != body:
		return
	var start: Transform3D = body.global_transform
	start.origin = snapshot.origin
	_constrain_world_pickup_preview(body, start, placer)

func _constrain_world_pickup_preview(body: RigidBody3D, previous: Transform3D, placer: Node3D = null) -> void:
	if !body.is_inside_tree() || !previous.is_finite() || !body.global_transform.is_finite():
		return
	var collision := body.get_node_or_null("Collision") as CollisionShape3D
	if collision == null || collision.shape == null:
		return
	var space := body.get_world_3d().direct_space_state
	var target := body.global_transform
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = collision.shape
	query.collision_mask = body.collision_mask
	query.exclude = [body.get_rid()]
	query.margin = 0.001
	var safe := previous
	# Resolve translation at the current orientation first. A blocked turn must
	# not veto movement away from a wall, nor blocked travel a clear turn.
	query.transform = previous * collision.transform
	query.motion = target.origin - previous.origin
	var fraction := space.cast_motion(query)
	if fraction.size() == 2:
		safe.origin += query.motion * fraction[0]
	query.transform = safe * collision.transform
	query.motion = Vector3.ZERO
	if !space.intersect_shape(query, 1).is_empty():
		safe.origin = previous.origin
	var blocked_travel := safe.origin.distance_squared_to(target.origin) > 0.00000001
	# Sample only the requested rotation at the reachable origin. Keep the last
	# clear intermediate pose; never rotate through an obstacle or push aside.
	var angle := previous.basis.get_rotation_quaternion().angle_to(target.basis.get_rotation_quaternion())
	var steps := maxi(1, int(ceil(angle / 0.025)))
	for step in range(1, steps + 1):
		var next := Transform3D(previous.basis.slerp(target.basis, float(step) / steps), safe.origin)
		query.transform = next * collision.transform
		if !space.intersect_shape(query, 1).is_empty():
			break
		safe = next
	body.global_transform = safe
	if blocked_travel && is_instance_valid(placer) && placer.get_parent() is Node3D:
		# Native scrolling moves a target, not the held body. Discard unreachable
		# distance so one backward scroll does not first pay off hidden overshoot.
		# Preserve native near/far limits, rotation controls and G/contact release.
		var local := (placer.get_parent() as Node3D).to_local(safe.origin)
		var forward := -placer.basis.z
		if forward.length_squared() > 0.000001:
			var reachable := local.dot(forward) / forward.length_squared()
			var old_distance: float = placer.distance
			placer.distance = clampf(reachable, placer.minDistance, placer.maxDistance)
			placer.position += forward * (placer.distance - old_distance)

func _capture_world_pickup_placement(snapshots: Dictionary) -> void:
	var placer = _lib._caller
	if !is_instance_valid(placer):
		return
	var placer_id: int = placer.get_instance_id()
	snapshots.erase(placer_id)
	var pickup = placer.get("placable")
	if !is_instance_valid(pickup):
		return
	var variant := _get_world_pickup_variant_for_body(pickup)
	if variant.is_empty() || variant.get("stabilize_drops", false) != true:
		return
	var pickup_id: int = pickup.get_instance_id()
	snapshots[placer_id] = {"id": pickup_id, "pose": pickup.global_transform}
	# A prior drop must never freeze or flatten a newly held preview.
	_clear_world_pickup_guard(pickup_id)
	var presenter := pickup.get_node_or_null("RTVLoreContactPresenter") as PaperContactPresenter
	if presenter != null:
		presenter.wall_tracking = false
		presenter.set_physics_process(false)

func _finish_world_pickup_placement(snapshots: Dictionary) -> void:
	var placer = _lib._caller
	if !is_instance_valid(placer):
		return
	var placer_id: int = placer.get_instance_id()
	var snapshot: Dictionary = snapshots.get(placer_id, {})
	var pickup_id: int = snapshot.get("id", 0)
	snapshots.erase(placer_id)
	if pickup_id == 0:
		return
	var pickup = instance_from_id(pickup_id)
	if !is_instance_valid(pickup):
		return
	if placer.get("placable") == pickup:
		_constrain_world_pickup_preview(pickup, snapshot.pose, placer)
		return
	if snapshot.has("supported_pose") && placer.get("placable") == null && !placer.gameData.isPlacing:
		# Do not override another hook's release or a changed pose. Native G's
		# exact kick identifies the synchronous path we planned in the pre-hook.
		if !pickup.freeze && pickup.gravity_scale > 0.0 && pickup.global_transform.is_equal_approx(snapshot.pose) && pickup.linear_velocity.is_equal_approx(Vector3(0, 0.1, 0)) && pickup.angular_velocity.is_equal_approx(Vector3.ONE):
			pickup.global_transform = snapshot.supported_pose
			pickup.linear_velocity = Vector3.ZERO
			pickup.angular_velocity = Vector3.ZERO
	# G release and Collided clear placable synchronously. Start a fresh,
	# bounded guard even when this same node has already been placed before.
	_stabilize_world_pickup_if_dropped(pickup_id)

func _register_world_pickup_monitor() -> void:
	var node_added_callback := Callable(
		self,
		"_on_tree_node_added_for_world_pickups"
	)
	if !get_tree().node_added.is_connected(node_added_callback):
		get_tree().node_added.connect(node_added_callback)
	print("[rtv_lore_elements] registered direct lore pickup monitor.")

# Compatibility entry point retained for the existing Hamina regression tools.
func _register_hamina_pickup_monitor() -> void:
	_register_world_pickup_monitor()

func _register_journal_input() -> void:
	if _lib.register(_lib.Registry.INPUTS, JOURNAL_INPUT_ACTION, {
		"display_label": _ui_text("input.open_journal"),
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
			_ui_text("mcm.page.title"),
			MCM_CONFIG_DIR,
			_ui_text("mcm.page.description"),
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
		"name": _ui_text("mcm.spawn_multiplier.name"),
		"tooltip": _ui_text("mcm.spawn_multiplier.tooltip"),
		"default": DEFAULT_LORE_NOTE_SPAWN_MULTIPLIER,
		"value": DEFAULT_LORE_NOTE_SPAWN_MULTIPLIER,
		"minRange": 0.0,
		"maxRange": MAX_LORE_NOTE_SPAWN_MULTIPLIER,
		"step": 0.1,
		"menu_pos": 1,
		"on_value_changed": "_on_mcm_value_changed"
	})
	config.set_value("Keycode", MCM_JOURNAL_HOTKEY_KEY, {
		"name": _ui_text("mcm.journal_hotkey.name"),
		"tooltip": _ui_text("mcm.journal_hotkey.tooltip"),
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
		user_dir.make_dir_recursive(MCM_CONFIG_DIR.trim_prefix("user://"))

func _on_mcm_config_updated(config: ConfigFile) -> void:
	_apply_mcm_config(config)
	print("[rtv_lore_elements] MCM configuration updated.")

func _on_mcm_value_changed(value_id: String, new_value, _menu) -> void:
	if value_id == MCM_SPAWN_MULTIPLIER_KEY:
		_lore_note_spawn_multiplier = clampf(float(new_value), 0.0, MAX_LORE_NOTE_SPAWN_MULTIPLIER)
	elif value_id == MCM_JOURNAL_HOTKEY_KEY:
		_apply_journal_hotkey_event(new_value)

func _apply_mcm_config(config: ConfigFile) -> void:
	_lore_note_spawn_multiplier = clampf(float(_get_mcm_entry_value(config, "Float", MCM_SPAWN_MULTIPLIER_KEY, DEFAULT_LORE_NOTE_SPAWN_MULTIPLIER)), 0.0, MAX_LORE_NOTE_SPAWN_MULTIPLIER)
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

			definition["note_type"] = _resolve_note_type(note_id, str(definition.get("note_type", DEFAULT_NOTE_TYPE)))
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

			_register_note_voiceover(note_id, definition)

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

	_register_note_voiceover(LEGACY_HELLO_NOTE_ID, LEGACY_HELLO_NOTE)

func _register_note_voiceover(note_id: String, definition: Dictionary) -> void:
	var voiceover_id := _get_note_voiceover_id(note_id, definition)
	if voiceover_id.is_empty():
		return
	if _registered_voiceover_ids.has(voiceover_id):
		return

	var audio_path := VOICEOVER_AUDIO_PATH_PREFIX + voiceover_id + ".wav"
	if !FileAccess.file_exists(audio_path):
		_warn_voiceover_once(voiceover_id, "missing voiceover audio for " + note_id + ": " + audio_path)
		return

	var audio_stream := AudioStreamWAV.load_from_file(audio_path)
	if audio_stream == null:
		_warn_voiceover_once(voiceover_id, "failed to load voiceover WAV for " + note_id + ": " + audio_path)
		return

	if !_lib.register(_lib.Registry.SOUNDS, voiceover_id, {
		"audioClips": [audio_stream],
		"volume": 0.0,
		"randomPitch": false,
	}):
		_warn_voiceover_once(voiceover_id, "failed to register voiceover sound: " + voiceover_id)
		return

	_registered_voiceover_ids[voiceover_id] = true

func _get_note_voiceover_id(note_id: String, definition: Dictionary) -> String:
	if !definition.has("voiceover_id") || definition["voiceover_id"] == null:
		return ""
	if typeof(definition["voiceover_id"]) != TYPE_STRING:
		_warn_voiceover_once(note_id + ":invalid_voiceover_id", "voiceover_id must be a string or null for " + note_id)
		return ""
	return str(definition["voiceover_id"]).strip_edges()

func _warn_voiceover_once(warning_id: String, message: String) -> void:
	if _voiceover_warning_ids.has(warning_id):
		return
	_voiceover_warning_ids[warning_id] = true
	push_warning("[rtv_lore_elements] " + message)

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
	if _notebook_portrait_enabled && note_id in NOTEBOOK_NOTE_IDS:
		item_path = NOTEBOOK_PORTRAIT_ITEM_PREFIX + note_id + ".tres"
	if _folded_compact_enabled && note_id in FOLDED_NOTE_IDS:
		item_path = FOLDED_COMPACT_ITEM_PREFIX + note_id + ".tres"

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
	# If migration hooks fail, the legacy four-cell item keeps its old price.
	if _folded_compact_enabled || note_id not in FOLDED_NOTE_IDS:
		item_data.value = int(definition.get("value", 15))
	item_data.rarity = int(definition.get("rarity", 0))
	item_data.usable = _has_reader_hook()
	item_data.phrase = _ui_text("item.action.read")
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
	_apply_note_scene_variant(note_id, scene_instance)
	_set_scene_owner(scene_instance, scene_instance)

	var packed_scene := PackedScene.new()
	var error := packed_scene.pack(scene_instance)
	scene_instance.free()
	if error != OK:
		push_warning("[rtv_lore_elements] PackedScene.pack failed for " + note_id + ": " + str(error))
		return null

	return packed_scene

func _apply_note_scene_variant(note_id: String, scene_instance: Node) -> void:
	var variant := _get_world_pickup_variant(note_id)
	if variant.is_empty():
		return

	var mesh_node := scene_instance.get_node_or_null("Mesh")
	var collision_node := scene_instance.get_node_or_null("Collision")
	if !(mesh_node is MeshInstance3D) || !(collision_node is CollisionShape3D):
		push_warning(
			"[rtv_lore_elements] shared note scene is missing pickup variant nodes; "
			+ "using the shared note pickup."
		)
		return

	var pickup_mesh := variant.get("mesh") as ArrayMesh
	var surface_materials: Dictionary = variant.get("materials_by_note_id", {})
	var pickup_material := surface_materials.get(note_id, variant.get("material")) as ShaderMaterial
	if pickup_mesh == null || pickup_material == null:
		return
	var world_scale := float(variant.get("world_scale", 1.0))
	var collision_size: Vector3 = variant.get("collision_size", Vector3.ONE)
	var collision_position: Vector3 = variant.get(
		"collision_position",
		Vector3.ZERO
	)
	var mesh_instance := mesh_node as MeshInstance3D
	var collision_shape := collision_node as CollisionShape3D
	var box_shape := BoxShape3D.new()
	box_shape.size = collision_size
	box_shape.margin = 0.001
	var mesh_bounds := pickup_mesh.get_aabb()
	var mesh_center := mesh_bounds.get_center()
	var mesh_position := Vector3(
		-mesh_center.x * world_scale,
		-mesh_bounds.position.y * world_scale,
		-mesh_center.z * world_scale
	)

	mesh_instance.transform = Transform3D.IDENTITY
	mesh_instance.scale = Vector3.ONE * world_scale
	mesh_instance.position = mesh_position
	mesh_instance.mesh = pickup_mesh
	var layer_materials: Array = variant.get("layer_materials", [])
	mesh_instance.material_override = pickup_material if layer_materials.is_empty() else null
	for surface in range(pickup_mesh.get_surface_count()):
		mesh_instance.set_surface_override_material(surface, null if layer_materials.is_empty() else layer_materials[surface])
	collision_shape.transform = Transform3D.IDENTITY
	collision_shape.position = collision_position
	collision_shape.shape = box_shape

func _get_world_pickup_variant(note_id: String) -> Dictionary:
	var variant_id := str(_world_pickup_variant_by_note_id.get(note_id, ""))
	if variant_id.is_empty():
		return {}
	return _world_pickup_variants.get(variant_id, {})

func _on_tree_node_added_for_world_pickups(node: Node) -> void:
	if _get_world_pickup_variant_for_body(node).is_empty():
		return
	call_deferred(
		"_stabilize_world_pickup_if_dropped",
		node.get_instance_id()
	)

func _get_world_pickup_variant_for_body(node: Node) -> Dictionary:
	if !(node is RigidBody3D) || !node.is_in_group("Item"):
		return {}
	var slot_data = node.get("slotData")
	if slot_data == null:
		return {}
	var item_data = slot_data.get("itemData")
	if item_data == null:
		return {}
	return _get_world_pickup_variant(str(item_data.get("file")))

func _is_hamina_pickup_body(node: Node) -> bool:
	var variant := _get_world_pickup_variant_for_body(node)
	return str(variant.get("id", "")) == "hamina_dispatch"

func _stabilize_world_pickup_if_dropped(pickup_id: int) -> void:
	var node = instance_from_id(pickup_id)
	if !(node is Node):
		return
	var variant := _get_world_pickup_variant_for_body(node)
	if variant.is_empty() || variant.get("stabilize_drops", false) != true:
		return
	var pickup_body := node as RigidBody3D
	if !pickup_body.is_inside_tree() || pickup_body.freeze || pickup_body.gravity_scale <= 0.0:
		return
	var variant_id := str(variant.get("id", "unknown"))
	var display_name := str(variant.get("display_name", variant_id))

	# Preserve the native release pose/spin. Automatic shape inertia allows
	# contact torque to tip a sheet instead of balancing a fixed flat plate.
	pickup_body.axis_lock_angular_x = false
	pickup_body.axis_lock_angular_z = false
	pickup_body.inertia = Vector3.ZERO
	pickup_body.continuous_cd = true
	if variant_id == "triage_tag":
		# Light card stock should lose its rapid contact wobble without axis
		# locks or imposed rest poses. This adds to the native world damping.
		pickup_body.angular_damp = 2.0
	if variant.has("angular_damp"):
		# Opt-in full-size stock damping: retain release spin, free tipping and
		# native sleep. Smaller accepted families keep their existing response.
		pickup_body.angular_damp = float(variant.angular_damp)
	var presenter := pickup_body.get_node_or_null("RTVLoreContactPresenter") as PaperContactPresenter
	if presenter == null:
		presenter = PaperContactPresenter.new()
		presenter.name = "RTVLoreContactPresenter"
		presenter.process_priority = 100
		presenter.coordinator = weakref(self)
		presenter.base_mesh_position = (pickup_body.get_node("Mesh") as MeshInstance3D).position
		pickup_body.add_child(presenter)
	presenter.set_process(true)
	if !presenter.wall_tracking:
		presenter.wall_offsets = _build_world_pickup_support_offsets(variant)
		presenter.wall_planes.clear()
		if !pickup_body.sleeping:
			_clear_world_pickup_wall_overlap(pickup_body, presenter.wall_offsets)
		presenter.wall_previous = pickup_body.global_transform
		presenter.wall_tracking = true
	presenter.set_physics_process(!pickup_body.sleeping)
	var rest_callback := _on_world_pickup_sleeping_changed.bind(pickup_id)
	if !pickup_body.sleeping_state_changed.is_connected(rest_callback):
		pickup_body.sleeping_state_changed.connect(rest_callback)
	if !_world_pickup_stabilization_logged.has(variant_id):
		print(
			"[rtv_lore_elements] "
			+ display_name
			+ " direct drop stabilization active: "
			+ "free angular settling, shape inertia and CCD enabled."
		)
		_world_pickup_stabilization_logged[variant_id] = true
		if variant_id == "hamina_dispatch":
			_hamina_pickup_stabilization_logged = true

	if !_world_pickup_guarded_ids.has(pickup_id):
		_world_pickup_guard_generation += 1
		_world_pickup_guarded_ids[pickup_id] = _world_pickup_guard_generation
		if variant_id == "hamina_dispatch":
			_hamina_guarded_pickup_ids[pickup_id] = true
		_guard_world_pickup_drop(
			pickup_body, pickup_id, variant, _world_pickup_guard_generation
		)

func _guard_world_pickup_drop(
	pickup_body: RigidBody3D,
	pickup_id: int,
	variant: Dictionary,
	generation: int
) -> void:
	var variant_id := str(variant.get("id", "unknown"))
	var display_name := str(variant.get("display_name", variant_id))
	var previous_position := pickup_body.global_position
	var previous_basis := pickup_body.global_basis
	var pickup_tree := pickup_body.get_tree()
	if pickup_tree == null:
		_clear_world_pickup_guard(pickup_id, generation)
		return
	for _frame in range(HAMINA_DROP_GUARD_FRAMES):
		await pickup_tree.physics_frame
		# An earlier coroutine must neither move this body nor clear a guard
		# that was rearmed by another release while it was suspended.
		if _world_pickup_guarded_ids.get(pickup_id, 0) != generation:
			return
		if !is_instance_valid(pickup_body):
			_clear_world_pickup_guard(pickup_id, generation)
			return

		if !pickup_body.is_inside_tree() || pickup_body.freeze || pickup_body.gravity_scale <= 0.0:
			break
		var current_position := pickup_body.global_position
		if (
			!previous_position.is_finite()
			|| !current_position.is_finite()
		):
			break
		var support_hit := _find_world_pickup_support_hit(
			pickup_body,
			previous_position,
			previous_basis,
			current_position,
			variant
		)
		if !support_hit.is_empty():
			# Correct only a demonstrated penetration, never a near-surface hit.
			# Do not freeze, flatten or erase spin: partial support must still tip.
			pickup_body.global_position.y += float(support_hit["lift"]) + HAMINA_DROP_GUARD_CLEARANCE
			var normal: Vector3 = support_hit["normal"]
			var inward_speed := pickup_body.linear_velocity.dot(normal)
			if inward_speed < 0.0:
				pickup_body.linear_velocity -= normal * inward_speed
			pickup_body.sleeping = false
			if !_world_pickup_guard_correction_logged.has(variant_id):
				print(
					"[rtv_lore_elements] "
					+ display_name
					+ " support guard "
					+ "recovered a crossed surface without freezing rotation."
				)
				_world_pickup_guard_correction_logged[variant_id] = true
				if variant_id == "hamina_dispatch":
					_hamina_drop_guard_correction_logged = true

		previous_position = pickup_body.global_position
		previous_basis = pickup_body.global_basis

	_clear_world_pickup_guard(pickup_id, generation)

func _on_world_pickup_sleeping_changed(pickup_id: int) -> void:
	var body = instance_from_id(pickup_id)
	if body is RigidBody3D && !body.sleeping:
		var presenter := body.get_node_or_null("RTVLoreContactPresenter") as PaperContactPresenter
		if presenter != null:
			presenter.set_process(true)
			presenter.set_physics_process(true)
	# Physics signals may arrive while the space is locked. Recheck native
	# sleep/placement state after dispatch, without installing a polling loop.
	call_deferred("_correct_world_pickup_rest_contact", pickup_id)

func _correct_world_pickup_rest_contact(pickup_id: int) -> void:
	var node = instance_from_id(pickup_id)
	if !(node is RigidBody3D):
		return
	var body := node as RigidBody3D
	if !body.is_inside_tree() || !body.sleeping || body.freeze || body.gravity_scale <= 0.0:
		return
	if !body.global_transform.is_finite():
		return
	var variant := _get_world_pickup_variant_for_body(body)
	if variant.is_empty() || variant.get("stabilize_drops", false) != true:
		return
	var correction := _world_pickup_contact_lift(body, variant)
	if is_finite(correction) && absf(correction) > WORLD_PICKUP_REST_TOLERANCE:
		# Transfer the rendered skin offset into the resting body's saved pose.
		# No visible pop: the mesh is already at this surface before sleep.
		body.global_position.y += correction
		body.sleeping = true
	var presenter := body.get_node_or_null("RTVLoreContactPresenter") as PaperContactPresenter
	if presenter != null:
		(body.get_node("Mesh") as MeshInstance3D).position = presenter.base_mesh_position
		presenter.set_process(false)
		presenter.wall_previous = body.global_transform
		presenter.set_physics_process(false)

func _present_world_pickup_contact(body: RigidBody3D, presenter: PaperContactPresenter) -> void:
	var mesh := body.get_node_or_null("Mesh") as MeshInstance3D
	if mesh == null:
		presenter.set_process(false)
		return
	mesh.position = presenter.base_mesh_position
	if !body.is_inside_tree() || body.freeze || body.gravity_scale <= 0.0:
		presenter.set_process(false)
		presenter.wall_tracking = false
		presenter.set_physics_process(false)
		return
	if body.sleeping:
		_correct_world_pickup_rest_contact(body.get_instance_id())
		return
	if !body.global_transform.is_finite():
		return
	var correction := _world_pickup_contact_lift(body, _get_world_pickup_variant_for_body(body))
	if is_finite(correction) && absf(correction) > WORLD_PICKUP_REST_TOLERANCE:
		# Render-only contact compensation: never teleport an awake rigid body,
		# alter spin/velocity, or remove contact torque that makes overhangs tip.
		mesh.global_position.y += correction

func _world_pickup_wall_ray(body: RigidBody3D, start: Vector3, end: Vector3, top: float) -> Dictionary:
	if start.is_equal_approx(end):
		return {}
	var space := body.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(start, end, body.collision_mask, [body.get_rid()])
	var hit := space.intersect_ray(query)
	if hit.is_empty() || !(hit.get("collider") is StaticBody3D):
		return {}
	var normal: Vector3 = hit["normal"]
	if absf(normal.y) > WORLD_PICKUP_WALL_MAX_NORMAL_Y || normal.length_squared() < 0.9:
		return {}
	# Require the same wall above the entire sheet. A stool/table side ending
	# at its support surface must not shove a naturally overhanging page away.
	var above: Vector3 = hit["position"]
	above.y = top + WORLD_PICKUP_WALL_TOP_CLEARANCE
	query.from = above + normal * WORLD_PICKUP_WALL_RELEASE_REACH
	query.to = above - normal * WORLD_PICKUP_WALL_RELEASE_REACH
	var upper := space.intersect_ray(query)
	if upper.is_empty() || upper["rid"] != hit["rid"] || (upper["normal"] as Vector3).dot(normal) < 0.95:
		return {}
	return hit

func _world_pickup_wall_top(body: RigidBody3D, offsets: Array) -> float:
	var top := -INF
	for offset in offsets:
		top = maxf(top, (body.global_transform * (offset as Vector3)).y)
	return top

func _world_pickup_wall_depth(body: RigidBody3D, offsets: Array, hit: Dictionary) -> float:
	var depth := -INF
	for offset in offsets:
		depth = maxf(depth, ((hit["position"] as Vector3) - body.global_transform * (offset as Vector3)).dot(hit["normal"]))
	return depth

func _move_world_pickup_out_of_wall(body: RigidBody3D, hit: Dictionary, depth: float) -> void:
	var normal: Vector3 = hit["normal"]
	body.global_position += normal * (depth + WORLD_PICKUP_WALL_CLEARANCE)
	var inward := body.linear_velocity.dot(normal)
	if inward < 0.0:
		body.linear_velocity -= normal * inward
	# Retain tangential motion and native angular contact response.

func _clear_world_pickup_wall_overlap(body: RigidBody3D, offsets: Array) -> void:
	# Only new releases: bounded probes can recover a shallow embedded start.
	# Choose the nearest viable exterior, not the far side of a hollow wall.
	for _pass in range(3):
		var best := {}
		var best_depth := WORLD_PICKUP_WALL_RELEASE_REACH
		var top := _world_pickup_wall_top(body, offsets)
		for offset in offsets:
			var point: Vector3 = body.global_transform * (offset as Vector3)
			for direction in [Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK,
				Vector3(-1, 0, -1).normalized(), Vector3(-1, 0, 1).normalized(),
				Vector3(1, 0, -1).normalized(), Vector3(1, 0, 1).normalized()]:
				var hit := _world_pickup_wall_ray(body, point + direction * WORLD_PICKUP_WALL_RELEASE_REACH, point, top)
				if hit.is_empty():
					continue
				var depth := _world_pickup_wall_depth(body, offsets, hit)
				if depth > 0.00001 && depth < best_depth:
					best = hit
					best_depth = depth
		if best.is_empty():
			break
		_move_world_pickup_out_of_wall(body, best, best_depth)

func _contain_world_pickup_motion(body: RigidBody3D, presenter: PaperContactPresenter) -> void:
	if !body.is_inside_tree() || body.freeze || body.gravity_scale <= 0.0:
		presenter.wall_tracking = false
		presenter.set_physics_process(false)
		return
	if !body.global_transform.is_finite():
		return
	if presenter.wall_tracking:
		# A slow edge-on fall can outlast the initial three-second coroutine.
		# Retain flat-floor recovery while awake, including a native wake after
		# expiry. Sloped contacts keep their accepted native settling: repeatedly
		# lifting those changes downhill drift. No sleeping/held/saved polling.
		if !body.sleeping && !_world_pickup_guarded_ids.has(body.get_instance_id()):
			var support := _find_world_pickup_support_hit(body, presenter.wall_previous.origin,
				presenter.wall_previous.basis, body.global_position, _get_world_pickup_variant_for_body(body))
			if !support.is_empty() && (support["normal"] as Vector3).y >= 0.999:
				body.global_position.y += float(support["lift"]) + HAMINA_DROP_GUARD_CLEARANCE
				var normal: Vector3 = support["normal"]
				var inward := body.linear_velocity.dot(normal)
				if inward < 0.0:
					# Supply the missed contact impulse at the recovered hit point.
					# Merely cancelling vertical speed can repeatedly lift an
					# upright sheet without letting that edge contact tip it.
					body.apply_impulse(-normal * inward * body.mass,
						(support["position"] as Vector3) - body.global_position)
		var top := _world_pickup_wall_top(body, presenter.wall_offsets)
		# Center plus all eight box corners catches translation and rotating
		# edges. Rays are front-facing, so an exterior-to-interior crossing is
		# recovered toward its recorded source side, not through the wall.
		for offset in presenter.wall_offsets:
			var start: Vector3 = presenter.wall_previous * (offset as Vector3)
			var end: Vector3 = body.global_transform * (offset as Vector3)
			var hit := _world_pickup_wall_ray(body, start, end, top)
			if hit.is_empty():
				continue
			var known := false
			for plane in presenter.wall_planes:
				if (plane["rid"] == hit["rid"]
					&& (plane["normal"] as Vector3).dot(hit["normal"]) > 0.999
					&& absf(((plane["position"] as Vector3) - (hit["position"] as Vector3)).dot(hit["normal"])) < 0.001):
					known = true
			if !known:
				presenter.wall_planes.append({"position": hit["position"], "normal": hit["normal"], "rid": hit["rid"]})
				if presenter.wall_planes.size() > 4: presenter.wall_planes.pop_front()
		# Let the native contact solver handle its small overlap/slop. Correcting
		# every fraction of a millimeter removes its contact torque and chatters.
		# Retain crossed planes so a slow sub-tolerance entry is still caught on
		# later frames; re-probe the actual finite wall before moving anything.
		var retained := []
		for plane in presenter.wall_planes:
			var depth := _world_pickup_wall_depth(body, presenter.wall_offsets, plane)
			if depth < -WORLD_PICKUP_WALL_TOP_CLEARANCE:
				continue
			if depth > WORLD_PICKUP_WALL_CONTACT_TOLERANCE:
				var normal: Vector3 = plane["normal"]
				var center: Vector3 = body.global_transform * (presenter.wall_offsets[0] as Vector3)
				var projected := center + normal * ((plane["position"] as Vector3) - center).dot(normal)
				var confirmed := _world_pickup_wall_ray(body, projected + normal * 0.01, projected - normal * 0.01, top)
				if confirmed.is_empty() || confirmed["rid"] != plane["rid"] || (confirmed["normal"] as Vector3).dot(normal) < 0.999:
					continue
				_move_world_pickup_out_of_wall(body, plane, depth)
			retained.append(plane)
		presenter.wall_planes = retained
	presenter.wall_previous = body.global_transform
	presenter.wall_tracking = true
	if body.sleeping:
		presenter.set_physics_process(false)

func _world_pickup_contact_lift(body: RigidBody3D, variant: Dictionary) -> float:
	var space := body.get_world_3d().direct_space_state
	var lift := -INF
	var supported := 0
	# Use the real visual hull, on both faces, rather than the padded collision
	# box. Correct only points with a nearby surface directly underneath them.
	for offset in variant.get("rest_offsets", PackedVector3Array()):
		var point := body.global_transform * (offset as Vector3)
		var hit := _cast_world_pickup_support_ray(space, body,
			point + Vector3.UP * HAMINA_DROP_GUARD_RECOVERY_HEIGHT,
			point - Vector3.UP * WORLD_PICKUP_REST_MAX_LOWERING)
		if hit.is_empty():
			continue
		supported += 1
		var normal: Vector3 = hit["normal"]
		var depth: float = ((hit["position"] as Vector3) - point).dot(normal)
		lift = maxf(lift, depth / normal.y)
	# Fully supported sheets already have their extremal hull points covered.
	# Partial support needs finite-face intersections, not an infinite plane:
	# a furniture edge may cross a face without passing under any hull vertex.
	if supported < variant.get("rest_offsets", PackedVector3Array()).size():
		lift = _world_pickup_interior_contact_lift(body, variant, lift)
	return lift + WORLD_PICKUP_REST_CLEARANCE

func _clip_world_pickup_face(poly: Array, a: Vector3, b: Vector3, side: float) -> Array:
	var result := []
	if poly.is_empty():
		return result
	var previous: Vector3 = poly.back()
	var edge := Vector2(b.x-a.x, b.z-a.z)
	var before := edge.cross(Vector2(previous.x-a.x, previous.z-a.z)) * side
	for point: Vector3 in poly:
		var after := edge.cross(Vector2(point.x-a.x, point.z-a.z)) * side
		if (before >= 0.0) != (after >= 0.0):
			result.append(previous.lerp(point, before / (before-after)))
		if after >= 0.0:
			result.append(point)
		previous = point
		before = after
	return result

func _world_pickup_interior_contact_lift(body: RigidBody3D, variant: Dictionary, lift: float) -> float:
	var hull = variant.get("contact_query")
	if !(hull is ConvexPolygonShape3D):
		return lift
	var space := body.get_world_3d().direct_space_state
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = hull
	query.transform = body.global_transform
	query.collision_mask = body.collision_mask
	query.exclude = [body.get_rid()]
	var overlaps := space.intersect_shape(query, 8)
	if overlaps.is_empty():
		return lift
	var faces: PackedVector3Array = body.global_transform * (variant["contact_faces"] as PackedVector3Array)
	var bounds: AABB = body.global_transform * (variant["contact_bounds"] as AABB)
	var nearby := bounds.grow(HAMINA_DROP_GUARD_RECOVERY_HEIGHT)
	var groups := []
	for group in variant["contact_groups"]:
		groups.append({"bounds":body.global_transform * (group.bounds as AABB), "indices":group.indices})
	for overlap in overlaps:
		var collider = overlap["collider"]
		if !(collider is StaticBody3D):
			continue
		var owner_id: int = collider.shape_find_owner(overlap["shape"])
		var node = collider.shape_owner_get_owner(owner_id)
		if !(node is CollisionShape3D):
			continue
		var support_faces := PackedVector3Array()
		if node.shape is ConcavePolygonShape3D:
			support_faces = node.shape.get_faces()
		elif node.shape is BoxShape3D:
			var box := BoxMesh.new()
			box.size = node.shape.size
			support_faces = box.get_faces()
		for index in range(0, support_faces.size(), 3):
			var a: Vector3 = node.global_transform * support_faces[index]
			var b: Vector3 = node.global_transform * support_faces[index+1]
			var c: Vector3 = node.global_transform * support_faces[index+2]
			var triangle_bounds := AABB(a, Vector3.ZERO).expand(b).expand(c)
			if !nearby.intersects(triangle_bounds.grow(0.00001)):
				continue
			var normal := (b-a).cross(c-a).normalized()
			if absf(normal.y) < HAMINA_DROP_GUARD_MIN_NORMAL_Y:
				continue
			var side := signf(Vector2(b.x-a.x,b.z-a.z).cross(Vector2(c.x-a.x,c.z-a.z)))
			var vertical_normal := normal / normal.y
			var plane_height := vertical_normal.dot(a)
			var validated := false
			var candidates := []
			for group in groups:
				var region: AABB = group.bounds
				if (region.end.x < triangle_bounds.position.x || region.position.x > triangle_bounds.end.x
					|| region.end.z < triangle_bounds.position.z || region.position.z > triangle_bounds.end.z):
					continue
				candidates.append_array(group.indices)
			for face in candidates:
				var p := faces[face]
				var q := faces[face+1]
				var r := faces[face+2]
				if (maxf(p.x,maxf(q.x,r.x)) < triangle_bounds.position.x
					|| minf(p.x,minf(q.x,r.x)) > triangle_bounds.end.x
					|| maxf(p.z,maxf(q.z,r.z)) < triangle_bounds.position.z
					|| minf(p.z,minf(q.z,r.z)) > triangle_bounds.end.z):
					continue
				# A linear plane separation cannot exceed its vertex maximum.
				# Once another contact is deeper, no clipping/allocation is needed.
				var maximum_depth := plane_height - minf(vertical_normal.dot(p), minf(vertical_normal.dot(q),vertical_normal.dot(r)))
				if maximum_depth <= lift || maximum_depth < -WORLD_PICKUP_REST_MAX_LOWERING:
					continue
				var poly := _clip_world_pickup_face([p,q,r], a,b,side)
				poly = _clip_world_pickup_face(poly, b,c,side)
				poly = _clip_world_pickup_face(poly, c,a,side)
				if poly.is_empty():
					continue
				if !validated:
					# Confirm the accessible upward face. This rejects a table's
					# underside and respects one-sided native collision geometry.
					var center := Vector3.ZERO
					for point: Vector3 in poly: center += point
					center /= poly.size()
					center = center.lerp((a+b+c)/3.0, 0.0001)
					center.y = a.y - (normal.x*(center.x-a.x)+normal.z*(center.z-a.z))/normal.y
					var hit := _cast_world_pickup_support_ray(space, body, center+Vector3.UP*0.001, center-Vector3.UP*0.001)
					if hit.is_empty() || hit.get("collider") != collider:
						break
					validated = true
				for point: Vector3 in poly:
					var height := a.y - (normal.x*(point.x-a.x)+normal.z*(point.z-a.z))/normal.y
					var depth := height-point.y
					if depth >= -WORLD_PICKUP_REST_MAX_LOWERING && depth <= HAMINA_DROP_GUARD_RECOVERY_HEIGHT:
						lift = maxf(lift, depth)
	return lift

func _clear_world_pickup_guard(pickup_id: int, generation: int = 0) -> void:
	if generation != 0 && _world_pickup_guarded_ids.get(pickup_id, 0) != generation:
		return
	_world_pickup_guarded_ids.erase(pickup_id)
	_hamina_guarded_pickup_ids.erase(pickup_id)

func _find_world_pickup_support_hit(
	pickup_body: RigidBody3D,
	previous_position: Vector3,
	previous_basis: Basis,
	current_position: Vector3,
	variant: Dictionary
) -> Dictionary:
	var world := pickup_body.get_world_3d()
	if world == null:
		return {}

	var space_state := world.direct_space_state
	var current_basis := pickup_body.global_basis
	var deepest_hit := {}
	for local_offset in _build_world_pickup_support_offsets(variant):
		var previous_support := (
			previous_position
			+ previous_basis * (local_offset as Vector3)
		)
		var current_support := (
			current_position
			+ current_basis * (local_offset as Vector3)
		)

		if current_support.y < previous_support.y:
			var segment_hit := _cast_world_pickup_support_ray(
				space_state,
				pickup_body,
				previous_support,
				current_support
			)
			deepest_hit = _choose_penetration_hit(deepest_hit, segment_hit, current_support)

		var recovery_hit := _cast_world_pickup_support_ray(
			space_state,
			pickup_body,
			current_support
			+ Vector3.UP * HAMINA_DROP_GUARD_RECOVERY_HEIGHT,
			current_support
		)
		deepest_hit = _choose_penetration_hit(deepest_hit, recovery_hit, current_support)

	return deepest_hit

func _choose_penetration_hit(current: Dictionary, candidate: Dictionary, point: Vector3) -> Dictionary:
	if candidate.is_empty():
		return current
	var normal: Vector3 = candidate["normal"]
	var position: Vector3 = candidate["position"]
	var depth := (position - point).dot(normal)
	if depth <= WORLD_PICKUP_PENETRATION_TOLERANCE:
		return current
	var lift := depth / normal.y
	if lift <= float(current.get("lift", 0.0)):
		return current
	candidate["lift"] = lift
	return candidate

func _build_world_pickup_support_offsets(variant: Dictionary) -> Array:
	var collision_size: Vector3 = variant.get("collision_size", Vector3.ZERO)
	var center: Vector3 = variant.get("collision_position", Vector3.ZERO)
	var offsets: Array = [center]
	# Both faces matter when the item tips or lands upside down.
	for x in [-0.5, 0.5]:
		for y in [-0.5, 0.5]:
			for z in [-0.5, 0.5]:
				offsets.append(center + collision_size * Vector3(x, y, z))
	return offsets

func _cast_world_pickup_support_ray(
	space_state: PhysicsDirectSpaceState3D,
	pickup_body: RigidBody3D,
	ray_from: Vector3,
	ray_to: Vector3
) -> Dictionary:
	if ray_from.is_equal_approx(ray_to):
		return {}
	var query := PhysicsRayQueryParameters3D.create(
		ray_from,
		ray_to,
		pickup_body.collision_mask,
		[pickup_body.get_rid()]
	)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.hit_from_inside = true
	var result := space_state.intersect_ray(query)
	if result.is_empty():
		return {}
	var collider = result.get("collider")
	if collider is RigidBody3D && (collider as RigidBody3D).is_in_group("Item"):
		return {}
	var normal: Vector3 = result.get("normal", Vector3.ZERO)
	if normal.y < HAMINA_DROP_GUARD_MIN_NORMAL_Y:
		return {}
	return result

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

func _on_interface_auto_place_post(target_item, target_grid, _source_grid, _usedrop, _result = null):
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

func _on_interface_map_post():
	_refresh_map_pin_layer_for_interface(_lib._caller)
	return null

func _on_tree_node_added_for_pins(node: Node) -> void:
	if node == null || node.name != "Interface":
		return
	call_deferred("_refresh_map_pin_layer_for_interface", node)

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
	var multiplier_floor: float = floor(_lore_note_spawn_multiplier)
	var guaranteed_extra := int(multiplier_floor) - 1
	for _index in guaranteed_extra:
		bucket.append(item_data)

	var fractional_extra: float = _lore_note_spawn_multiplier - multiplier_floor
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

func _refresh_map_pin_layer() -> void:
	_refresh_map_pin_layer_for_interface(_get_active_interface_node())

func _refresh_map_pin_layer_for_interface(interface_node: Node) -> void:
	if interface_node == null || !is_instance_valid(interface_node):
		set_process(false)
		return

	var navigator = interface_node.get_node_or_null("Tools/Map/Elements/Navigator")
	var map_scroll = interface_node.get_node_or_null("Tools/Map/Elements/Navigator/Scroll")
	if navigator == null || !(navigator is Control):
		set_process(false)
		return
	if map_scroll == null || !(map_scroll is Control):
		set_process(false)
		return

	_connect_map_pin_visibility_signal(interface_node)

	var pinned_note_ids: Array = []
	for note_id in _journal_discovered_ids:
		var pin_data := _get_note_pin_data(str(note_id))
		if pin_data.is_empty():
			continue
		pinned_note_ids.append(str(note_id))

	if pinned_note_ids.is_empty():
		_remove_map_pin_layer(navigator)
		_sync_map_pin_processing_for_interface(interface_node)
		return

	var pin_layer := _ensure_map_pin_layer(navigator as Control)
	if pin_layer == null:
		set_process(false)
		return

	_clear_map_pin_layer(pin_layer)
	for note_id in pinned_note_ids:
		var pin_data := _get_note_pin_data(str(note_id))
		pin_layer.add_child(_build_map_pin_marker(str(note_id), pin_data))

	navigator.move_child(pin_layer, navigator.get_child_count() - 1)
	_update_map_pin_screen_positions_for_interface(interface_node)
	_sync_map_pin_processing_for_interface(interface_node)

func _ensure_map_pin_layer(navigator: Control) -> Control:
	var existing = navigator.get_node_or_null(MAP_PIN_LAYER_NAME)
	if existing != null && existing is Control:
		return existing
	if existing != null:
		navigator.remove_child(existing)
		existing.free()

	var pin_layer := Control.new()
	pin_layer.name = MAP_PIN_LAYER_NAME
	pin_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pin_layer.clip_contents = true
	pin_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pin_layer.z_index = 2000
	navigator.add_child(pin_layer)
	return pin_layer

func _clear_map_pin_layer(pin_layer: Control) -> void:
	for child in pin_layer.get_children():
		pin_layer.remove_child(child)
		child.free()

func _remove_map_pin_layer(navigator: Node) -> void:
	var existing = navigator.get_node_or_null(MAP_PIN_LAYER_NAME)
	if existing == null:
		return
	navigator.remove_child(existing)
	existing.free()

func _connect_map_pin_visibility_signal(interface_node: Node) -> void:
	var map_ui = interface_node.get_node_or_null("Tools/Map")
	if map_ui == null || !(map_ui is CanvasItem):
		return

	var callback := Callable(self, "_on_map_ui_visibility_changed").bind(interface_node)
	if !(map_ui as CanvasItem).visibility_changed.is_connected(callback):
		(map_ui as CanvasItem).visibility_changed.connect(callback)

func _on_map_ui_visibility_changed(interface_node: Node) -> void:
	if interface_node == null || !is_instance_valid(interface_node):
		set_process(false)
		return
	if _is_map_ui_visible(interface_node):
		_refresh_map_pin_layer_for_interface(interface_node)
	else:
		_sync_map_pin_processing_for_interface(interface_node)

func _resolve_note_type(note_id: String, raw_note_type: String) -> String:
	var note_type := raw_note_type.strip_edges()
	if note_type.is_empty():
		return DEFAULT_NOTE_TYPE
	if _note_type_styles.has(note_type):
		return note_type
	_warn_note_type_once(note_id + ":unknown_type", "unknown note_type '" + note_type + "' for " + note_id + "; using " + DEFAULT_NOTE_TYPE)
	return DEFAULT_NOTE_TYPE

func _get_note_type(note_id: String) -> String:
	if !_notes.has(note_id):
		return DEFAULT_NOTE_TYPE
	var note: Dictionary = _notes[note_id]
	return _resolve_note_type(note_id, str(note.get("note_type", DEFAULT_NOTE_TYPE)))

func _get_note_type_style(note_id: String) -> Dictionary:
	var note_type := _get_note_type(note_id)
	if _note_type_styles.has(note_type):
		return (_note_type_styles[note_type] as Dictionary).duplicate(true)
	return (_note_type_styles.get(DEFAULT_NOTE_TYPE, FALLBACK_NOTE_TYPE_STYLES[DEFAULT_NOTE_TYPE]) as Dictionary).duplicate(true)

func _style_color(style: Dictionary, key: String, fallback: Color) -> Color:
	var value = style.get(key, "")
	if value is Color:
		return value
	if value is String:
		var text := str(value).strip_edges()
		if Color.html_is_valid(text):
			return Color.html(text)
	return fallback

func _style_vector2(style: Dictionary, key: String, fallback: Vector2) -> Vector2:
	var value = style.get(key, null)
	if value is Vector2:
		return value
	if typeof(value) == TYPE_ARRAY && value.size() >= 2:
		var x = value[0]
		var y = value[1]
		if (x is float || x is int) && (y is float || y is int):
			return Vector2(float(x), float(y))
	return fallback

func _style_margins(style: Dictionary) -> Dictionary:
	var margins := {
		"left": 38,
		"top": 30,
		"right": 38,
		"bottom": 28,
	}
	var raw_margins = style.get("margins", {})
	if typeof(raw_margins) != TYPE_DICTIONARY:
		return margins
	for key in margins.keys():
		var value = raw_margins.get(key, margins[key])
		if value is float || value is int:
			margins[key] = int(value)
	return margins

func _get_note_pin_data(note_id: String) -> Dictionary:
	if !_notes.has(note_id):
		return {}

	var note: Dictionary = _notes[note_id]
	if !note.has("pinned_location") || note["pinned_location"] == null:
		return {}

	var raw_location = note["pinned_location"]
	if typeof(raw_location) != TYPE_DICTIONARY:
		_warn_pin_once(note_id + ":location_type", "pinned_location must be an object or null for " + note_id)
		return {}

	var location: Dictionary = raw_location
	if !location.has("x") || !location.has("y"):
		_warn_pin_once(note_id + ":location_xy", "pinned_location requires x and y map-pixel coordinates for " + note_id)
		return {}

	var raw_x = location["x"]
	var raw_y = location["y"]
	if !(raw_x is float) && !(raw_x is int):
		_warn_pin_once(note_id + ":location_x", "pinned_location.x must be numeric for " + note_id)
		return {}
	if !(raw_y is float) && !(raw_y is int):
		_warn_pin_once(note_id + ":location_y", "pinned_location.y must be numeric for " + note_id)
		return {}

	return {
		"position": Vector2(float(raw_x), float(raw_y)),
		"label": _get_note_pin_label(note_id, note),
		"accent_color": _style_color(_get_note_type_style(note_id), "accent_color", Color(0.78, 0.12, 0.08)),
	}

func _get_note_pin_label(note_id: String, note: Dictionary) -> String:
	var default_label := str(note.get("name", note_id))
	if !note.has("pin_label") || note["pin_label"] == null:
		return default_label

	var label_key := str(note["pin_label"]).strip_edges()
	if label_key.is_empty():
		return default_label
	return _ui_text(label_key, label_key)

func _build_map_pin_marker(note_id: String, pin_data: Dictionary) -> Control:
	var marker := Control.new()
	marker.name = MAP_PIN_MARKER_NAME_PREFIX + note_id
	marker.set_meta("map_position", pin_data["position"])
	marker.position = Vector2(-10000.0, -10000.0)
	marker.size = Vector2(240.0, 36.0)
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.z_index = 210

	var accent: Color = pin_data.get("accent_color", Color(0.78, 0.12, 0.08))
	var accent_light := accent.lerp(Color(1.0, 0.92, 0.68), 0.42)
	var accent_dark := accent.darkened(0.28)

	var ring_style := StyleBoxFlat.new()
	ring_style.bg_color = Color(accent.r, accent.g, accent.b, 0.18)
	ring_style.border_color = Color(accent_light.r, accent_light.g, accent_light.b, 0.95)
	ring_style.set_border_width_all(2)

	var ring := Panel.new()
	ring.name = "Ring"
	ring.position = Vector2(-12.0, -12.0)
	ring.size = Vector2(24.0, 24.0)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.add_theme_stylebox_override("panel", ring_style)
	marker.add_child(ring)

	var dot_style := StyleBoxFlat.new()
	dot_style.bg_color = Color(accent.r, accent.g, accent.b, 0.95)
	dot_style.border_color = Color(accent_light.r, accent_light.g, accent_light.b, 1.0)
	dot_style.set_border_width_all(3)

	var dot := Panel.new()
	dot.name = "Dot"
	dot.position = Vector2(-7.0, -7.0)
	dot.size = Vector2(14.0, 14.0)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dot.add_theme_stylebox_override("panel", dot_style)
	marker.add_child(dot)

	var label_style := StyleBoxFlat.new()
	label_style.bg_color = Color(0.03, 0.025, 0.02, 0.82)
	label_style.border_color = Color(accent_dark.r, accent_dark.g, accent_dark.b, 0.95)
	label_style.set_border_width_all(1)
	label_style.set_content_margin_all(5.0)

	var label_text := str(pin_data["label"])
	var label_font_size := 16
	var label := Label.new()
	label.text = label_text
	label.clip_text = true
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", Color(0.94, 0.88, 0.72, 1.0))
	label.add_theme_font_size_override("font_size", label_font_size)
	var label_panel_width := _get_map_pin_label_width(label, label_text, label_font_size)

	var label_panel := PanelContainer.new()
	label_panel.name = "Label"
	label_panel.position = Vector2(14.0, -17.0)
	label_panel.size = Vector2(label_panel_width, 30.0)
	label_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_panel.add_theme_stylebox_override("panel", label_style)
	marker.add_child(label_panel)
	label_panel.add_child(label)
	marker.size = Vector2(label_panel.position.x + label_panel_width, 36.0)

	return marker

func _get_map_pin_label_width(label: Label, label_text: String, font_size: int) -> float:
	var text_width := float(label_text.length()) * float(font_size) * 0.55
	var font := label.get_theme_font("font")
	if font != null:
		text_width = font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	return clampf(text_width + 14.0, 48.0, 210.0)

func _sync_map_pin_processing_for_interface(interface_node: Node) -> void:
	var should_process := false
	if interface_node != null && is_instance_valid(interface_node) && _is_map_ui_visible(interface_node):
		var navigator = interface_node.get_node_or_null("Tools/Map/Elements/Navigator")
		if navigator != null:
			var pin_layer = navigator.get_node_or_null(MAP_PIN_LAYER_NAME)
			should_process = pin_layer != null && pin_layer is Control && pin_layer.get_child_count() > 0
	set_process(should_process)

func _is_map_ui_visible(interface_node: Node) -> bool:
	var map_ui = interface_node.get_node_or_null("Tools/Map")
	return map_ui != null && map_ui is CanvasItem && (map_ui as CanvasItem).is_visible_in_tree()

func _update_map_pin_screen_positions() -> void:
	_update_map_pin_screen_positions_for_interface(_get_active_interface_node())

func _update_map_pin_screen_positions_for_interface(interface_node: Node) -> void:
	if interface_node == null || !is_instance_valid(interface_node):
		set_process(false)
		return
	if !_is_map_ui_visible(interface_node):
		set_process(false)
		return

	var navigator = interface_node.get_node_or_null("Tools/Map/Elements/Navigator")
	var map_scroll = interface_node.get_node_or_null("Tools/Map/Elements/Navigator/Scroll")
	if navigator == null || map_scroll == null:
		set_process(false)
		return

	var pin_layer = navigator.get_node_or_null(MAP_PIN_LAYER_NAME)
	if pin_layer == null || !(pin_layer is Control):
		set_process(false)
		return
	if pin_layer.get_child_count() <= 0:
		set_process(false)
		return

	var zoom := 1.0
	var zoom_value = map_scroll.get("zoomLevel")
	if zoom_value is float || zoom_value is int:
		zoom = float(zoom_value)

	var scroll_offset := Vector2(float(map_scroll.get("scroll_horizontal")), float(map_scroll.get("scroll_vertical")))
	var scroll_origin := Vector2.ZERO
	if map_scroll is Control && pin_layer is Control:
		scroll_origin = (map_scroll as Control).global_position - (pin_layer as Control).global_position

	for child in pin_layer.get_children():
		if !child.has_meta("map_position") || !(child is Control):
			continue
		var map_position = child.get_meta("map_position")
		if !(map_position is Vector2):
			continue
		var screen_position := scroll_origin + (map_position as Vector2) * zoom - scroll_offset
		var pin_scale := clampf(zoom / MAP_PIN_BASE_ZOOM, 0.58, 1.0)
		(child as Control).position = screen_position
		(child as Control).scale = Vector2(pin_scale, pin_scale)

func _warn_pin_once(warning_id: String, message: String) -> void:
	if _pin_warning_ids.has(warning_id):
		return
	_pin_warning_ids[warning_id] = true
	push_warning("[rtv_lore_elements] " + message)

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

func _get_reader_presentation_style(note_id: String) -> Dictionary:
	var base := _get_note_type_style(note_id)
	var pages: Array = _notes.get(note_id, {}).get("pages", [])
	return READER_PRESENTATION.style(note_id, base) if READER_PRESENTATION.supports(note_id, pages) else base

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
	var note_style := _get_reader_presentation_style(note_id)
	var paper_size := _style_vector2(note_style, "canvas_size", Vector2(680, 500))
	# Reflow text rather than shrink fonts on smaller viewports. The original
	# style data remains untouched for map pins and other consumers.
	var available := _get_modal_viewport_size() - Vector2(64, 64)
	paper_size = READER_PRESENTATION.fit(paper_size, available, bool(note_style.get("portrait_reader", false)))
	note_style = note_style.duplicate(true)
	note_style["canvas_size"] = [paper_size.x, paper_size.y]
	var margins := _style_margins(note_style)
	var ink_color := _style_color(note_style, "ink_color", Color(0.12, 0.1, 0.07))

	_reader = CanvasLayer.new()
	_reader.name = "RtvLoreNoteReader"
	_reader.layer = 140

	var modal_root := _build_modal_root("ReaderModalRoot", Color(0.02, 0.02, 0.018, 0.82))
	_reader.add_child(modal_root)

	var center := CenterContainer.new()
	center.name = "Center"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_root.add_child(center)

	var panel := PanelContainer.new()
	panel.name = "Paper"
	panel.custom_minimum_size = paper_size
	panel.rotation_degrees = float(note_style.get("rotation_degrees", -0.8))
	panel.pivot_offset = paper_size * 0.5
	panel.add_theme_stylebox_override("panel", _build_paper_style(note_style))
	center.add_child(panel)

	var paper_root := Control.new()
	paper_root.name = "PaperRoot"
	paper_root.custom_minimum_size = paper_size
	paper_root.clip_contents = true
	panel.add_child(paper_root)
	_add_reader_paper_texture(paper_root, note_style)
	_add_reader_decorations(paper_root, note_style)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", margins["left"])
	margin.add_theme_constant_override("margin_top", margins["top"])
	margin.add_theme_constant_override("margin_right", margins["right"])
	margin.add_theme_constant_override("margin_bottom", margins["bottom"])
	paper_root.add_child(margin)

	var layout := VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override("separation", 10)
	margin.add_child(layout)

	_reader_title = Label.new()
	_reader_title.name = "Title"
	_reader_title.horizontal_alignment = int(note_style.get("title_alignment", HORIZONTAL_ALIGNMENT_CENTER))
	_reader_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reader_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reader_title.add_theme_color_override("font_color", ink_color)
	_reader_title.add_theme_font_size_override("font_size", int(note_style.get("title_font_size", 24)))
	layout.add_child(_reader_title)
	var heading_rule := HSeparator.new()
	var rule_style := StyleBoxLine.new()
	rule_style.color = _style_color(note_style, "border_color", Color(.3,.25,.2)) * Color(1,1,1,.24)
	heading_rule.add_theme_stylebox_override("separator", rule_style)
	heading_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(heading_rule)

	_reader_body = RichTextLabel.new()
	_reader_body.name = "Body"
	_reader_body.bbcode_enabled = false
	_reader_body.fit_content = false
	_reader_body.scroll_active = true
	_reader_body.mouse_filter = Control.MOUSE_FILTER_STOP
	_reader_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reader_body.custom_minimum_size = Vector2(0, 120)
	_reader_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_reader_body.selection_enabled = true
	_reader_body.add_theme_constant_override("line_separation", 3)
	_reader_body.add_theme_color_override("default_color", ink_color)
	_reader_body.add_theme_font_size_override("normal_font_size", int(note_style.get("body_font_size", 25)))
	var body_font := str(note_style.get("body_font", "handwritten"))
	if body_font == "handwritten" && _reader_font != null:
		_reader_body.add_theme_font_override("normal_font", _reader_font)
	elif body_font == "mono" && _reader_mono_font != null:
		_reader_body.add_theme_font_override("normal_font", _reader_mono_font)
	elif body_font == "handprint" && _reader_print_font != null:
		_reader_body.add_theme_font_override("normal_font", _reader_print_font)
	layout.add_child(_reader_body)

	var footer := HBoxContainer.new()
	footer.name = "PageNavigation"
	footer.add_theme_constant_override("separation", 10)
	layout.add_child(footer)

	_reader_prev_button = _build_reader_button(_ui_text("reader.prev"), Vector2(92, 40), note_style)
	_reader_prev_button.pressed.connect(_show_previous_page)
	footer.add_child(_reader_prev_button)

	_reader_page_counter = Label.new()
	_reader_page_counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reader_page_counter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_reader_page_counter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reader_page_counter.add_theme_color_override("font_color", ink_color)
	_reader_page_counter.add_theme_font_size_override("font_size", 18)
	footer.add_child(_reader_page_counter)

	_reader_next_button = _build_reader_button(_ui_text("reader.next"), Vector2(92, 40), note_style)
	_reader_next_button.pressed.connect(_show_next_page)
	footer.add_child(_reader_next_button)

	var close_button := _build_reader_button(_ui_text("common.close"), Vector2(112, 40), note_style)
	close_button.name = "Close"
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_button.pressed.connect(_request_close_reader)
	layout.add_child(close_button)

	var attach_parent := _get_overlay_attach_parent(interface_node)
	attach_parent.add_child(_reader)
	get_viewport().size_changed.connect(_resize_note_reader, CONNECT_DEFERRED)
	_refresh_reader_page()
	_play_reader_voiceover()

func _resize_note_reader() -> void:
	if !is_instance_valid(_reader):
		return
	var modal: Control = _reader.get_node("ReaderModalRoot")
	modal.custom_minimum_size = Vector2.ZERO
	_sync_modal_root_size(modal)
	var panel: Control = modal.get_node("Center/Paper")
	var paper: Control = panel.get_node("PaperRoot")
	var style := _get_reader_presentation_style(_reader_note_id).duplicate(true)
	var wanted := _style_vector2(style, "canvas_size", Vector2(680,500))
	var available := _get_modal_viewport_size() - Vector2(64,64)
	var fitted := READER_PRESENTATION.fit(wanted, available, bool(style.get("portrait_reader", false)))
	panel.custom_minimum_size = fitted
	paper.custom_minimum_size = fitted
	panel.pivot_offset = fitted * .5
	var decorations := paper.get_node_or_null("ReaderDecorations")
	if decorations != null:
		paper.remove_child(decorations)
		decorations.queue_free()
	style["canvas_size"] = [fitted.x,fitted.y]
	_add_reader_decorations(paper,style)
	paper.move_child(paper.get_node("ReaderDecorations"),1 if paper.has_node("PaperStock") else 0)

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
	_refresh_map_pin_layer()

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
	if changed:
		_refresh_map_pin_layer()
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

	var modal_root := _build_modal_root("JournalModalRoot", Color(0.02, 0.02, 0.018, 0.76))
	_journal.add_child(modal_root)

	var center := CenterContainer.new()
	center.name = "Center"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_root.add_child(center)

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
	title.text = _ui_text("journal.title")
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
	close_button.text = _ui_text("common.close")
	close_button.custom_minimum_size = Vector2(120, 36)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_button.pressed.connect(_request_close_journal)
	layout.add_child(close_button)

	var attach_parent := _get_overlay_attach_parent(interface_node)
	attach_parent.add_child(_journal)

func _get_overlay_attach_parent(interface_node: Node) -> Node:
	if interface_node != null && is_instance_valid(interface_node) && interface_node.is_visible_in_tree():
		return interface_node
	if get_tree().current_scene != null:
		return get_tree().current_scene
	return self

func _build_modal_root(root_name: String, overlay_color: Color) -> Control:
	var root := Control.new()
	root.name = root_name
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_sync_modal_root_size(root)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.gui_input.connect(_consume_modal_gui_input.bind(root))
	root.call_deferred("set_size", _get_modal_viewport_size())

	var overlay := ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = overlay_color
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(overlay)
	return root

func _consume_modal_gui_input(_event: InputEvent, modal_root: Control) -> void:
	if modal_root != null && is_instance_valid(modal_root):
		modal_root.accept_event()
	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()

func _sync_modal_root_size(modal_root: Control) -> void:
	if modal_root == null || !is_instance_valid(modal_root):
		return
	modal_root.position = Vector2.ZERO
	modal_root.size = _get_modal_viewport_size()
	modal_root.custom_minimum_size = modal_root.size

func _get_modal_viewport_size() -> Vector2:
	var viewport := get_viewport()
	if viewport == null:
		return Vector2(1920, 1080)
	return viewport.get_visible_rect().size

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
		empty.text = _ui_text("journal.empty_state")
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

func _request_close_journal() -> void:
	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()
	call_deferred("_close_journal")

func _build_paper_style(note_style: Dictionary) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _style_color(note_style, "paper_color", Color(0.78, 0.72, 0.58))
	style.border_color = _style_color(note_style, "border_color", Color(0.36, 0.27, 0.16))
	style.set_border_width_all(1)
	style.corner_radius_top_left = 1
	style.corner_radius_top_right = 1
	style.corner_radius_bottom_right = 1
	style.corner_radius_bottom_left = 1
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.36)
	style.shadow_size = 18
	style.shadow_offset = Vector2(0, 5)
	return style

func _add_reader_paper_texture(parent: Control, note_style: Dictionary) -> void:
	var path := str(note_style.get("paper_texture", ""))
	if path.is_empty():
		return
	# Raw PNG decoding works in the VMZ without editor .import dependencies.
	if !_reader_paper_textures.has(path):
		if !FileAccess.file_exists(path):
			_warn_note_type_once(path, "reader paper texture unavailable; retaining plain paper.")
			return
		var image := Image.new()
		if image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK:
			_warn_note_type_once(path, "reader paper texture invalid; retaining plain paper.")
			return
		_reader_paper_textures[path] = ImageTexture.create_from_image(image)
	var texture: Texture2D = _reader_paper_textures[path]
	var region: Array = note_style.get("paper_region", [])
	if region.size() != 4:
		return
	var area := Rect2(float(region[0]),float(region[1]),float(region[2]),float(region[3]))
	if !Rect2(Vector2.ZERO,texture.get_size()).encloses(area) || !area.has_area():
		return
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = area
	atlas.filter_clip = true
	var stock := TextureRect.new()
	stock.name = "PaperStock"
	stock.texture = atlas
	stock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stock.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	stock.modulate.a = clampf(float(note_style.get("paper_opacity", .4)),0,1)
	stock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stock.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(stock)

func _build_reader_button(text: String, min_size: Vector2, note_style: Dictionary) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = min_size
	button.add_theme_color_override("font_color", _style_color(note_style, "ink_color", Color(0.15, 0.12, 0.08)))
	button.add_theme_color_override("font_disabled_color", Color(0.28, 0.25, 0.2, 0.45))
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_stylebox_override("normal", _build_reader_button_style(note_style, 0.12))
	button.add_theme_stylebox_override("hover", _build_reader_button_style(note_style, 0.2))
	button.add_theme_stylebox_override("pressed", _build_reader_button_style(note_style, 0.28))
	button.add_theme_stylebox_override("disabled", _build_reader_button_style(note_style, 0.05))
	var focus_style := StyleBoxFlat.new()
	focus_style.draw_center = false
	focus_style.border_color = _style_color(note_style, "ink_color", Color(.15,.12,.08))
	focus_style.set_border_width_all(2)
	button.add_theme_stylebox_override("focus", focus_style)
	return button

func _build_reader_button_style(note_style: Dictionary, alpha: float) -> StyleBoxFlat:
	var accent := _style_color(note_style, "accent_color", Color(0.45, 0.28, 0.16))
	var border := _style_color(note_style, "border_color", Color(0.36, 0.27, 0.16))
	var style := StyleBoxFlat.new()
	style.bg_color = Color(accent.r, accent.g, accent.b, alpha)
	style.border_color = Color(border.r, border.g, border.b, clampf(alpha + 0.28, 0.0, 0.85))
	style.set_border_width_all(1)
	style.set_content_margin_all(6.0)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	return style

func _add_reader_decorations(parent: Control, note_style: Dictionary) -> void:
	var decorations := Control.new()
	decorations.name = "ReaderDecorations"
	decorations.mouse_filter = Control.MOUSE_FILTER_IGNORE
	decorations.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(decorations)
	parent = decorations
	var decoration := str(note_style.get("decoration", "notice"))
	var paper_size := _style_vector2(note_style, "canvas_size", Vector2(680, 500))
	var accent := _style_color(note_style, "accent_color", Color(0.64, 0.18, 0.12))
	var border := _style_color(note_style, "border_color", Color(0.36, 0.27, 0.16))
	match decoration:
		"header_stamp":
			_add_reader_stamp(parent, note_style, Vector2(paper_size.x - 154.0, 20.0), Vector2(104, 26), -3.0)
		"ruled":
			_add_reader_ruled_lines(parent, paper_size, Color(accent.r, accent.g, accent.b, 0.09))
		"letter":
			_add_reader_stamp(parent, note_style, Vector2(paper_size.x - 146.0, 20.0), Vector2(86, 24), -3.0)
		"ledger":
			_add_reader_ruled_lines(parent, paper_size, Color(border.r, border.g, border.b, 0.07))
			_add_reader_line(parent, Vector2(32, 116), Vector2(1, maxf(0,paper_size.y - 266)), Color(border.r, border.g, border.b, 0.18))
		"map":
			_add_reader_line(parent, Vector2(paper_size.x * 0.5, 24), Vector2(1, paper_size.y - 48), Color(border.r, border.g, border.b, 0.06))
		"triage_tag":
			_add_reader_grommet(parent, Vector2(46, 24), border)
			_add_reader_stamp(parent, note_style, Vector2(paper_size.x - 142.0, 20.0), Vector2(92, 26), -3.0)
		"none":
			pass
		_:
			_add_reader_stamp(parent, note_style, Vector2(paper_size.x - 146.0, 20.0), Vector2(96, 26), -3.0)

func _add_reader_line(parent: Control, position: Vector2, size: Vector2, color: Color) -> void:
	var line := ColorRect.new()
	line.position = position
	line.size = size
	line.color = color
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(line)

func _add_reader_ruled_lines(parent: Control, paper_size: Vector2, color: Color) -> void:
	var y := 138.0
	while y < paper_size.y - 150.0:
		_add_reader_line(parent, Vector2(44, y), Vector2(paper_size.x - 88.0, 1.0), color)
		y += 31.0

func _add_reader_signature_line(parent: Control, paper_size: Vector2, border: Color) -> void:
	_add_reader_line(parent, Vector2(paper_size.x - 220.0, paper_size.y - 68.0), Vector2(150, 1), Color(border.r, border.g, border.b, 0.22))

func _add_reader_grommet(parent: Control, position: Vector2, border: Color) -> void:
	var ring_style := StyleBoxFlat.new()
	ring_style.bg_color = Color(0.04, 0.035, 0.025, 0.08)
	ring_style.border_color = Color(border.r, border.g, border.b, 0.52)
	ring_style.set_border_width_all(2)
	ring_style.corner_radius_top_left = 9
	ring_style.corner_radius_top_right = 9
	ring_style.corner_radius_bottom_right = 9
	ring_style.corner_radius_bottom_left = 9

	var ring := Panel.new()
	ring.position = position
	ring.size = Vector2(18, 18)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.add_theme_stylebox_override("panel", ring_style)
	parent.add_child(ring)

func _add_reader_stamp(parent: Control, note_style: Dictionary, position: Vector2, size: Vector2, rotation: float) -> void:
	var stamp_key := str(note_style.get("stamp_key", "reader.stamp.notice"))
	var accent := _style_color(note_style, "accent_color", Color(0.64, 0.18, 0.12))
	var stamp_style := StyleBoxFlat.new()
	stamp_style.bg_color = Color(accent.r, accent.g, accent.b, 0.04)
	stamp_style.border_color = Color(accent.r, accent.g, accent.b, 0.42)
	stamp_style.set_border_width_all(1)
	stamp_style.corner_radius_top_left = 1
	stamp_style.corner_radius_top_right = 1
	stamp_style.corner_radius_bottom_right = 1
	stamp_style.corner_radius_bottom_left = 1

	var stamp := PanelContainer.new()
	stamp.position = position
	stamp.size = size
	stamp.rotation_degrees = rotation
	stamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stamp.add_theme_stylebox_override("panel", stamp_style)
	parent.add_child(stamp)

	var label := Label.new()
	label.text = _ui_text(stamp_key, stamp_key)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(accent.r, accent.g, accent.b, 0.58))
	label.add_theme_font_size_override("font_size", 13)
	stamp.add_child(label)

func _show_previous_page() -> void:
	if _reader_page_index <= 0:
		return
	_stop_reader_voiceover()
	_reader_page_index -= 1
	_refresh_reader_page()

func _show_next_page() -> void:
	var pages := _get_reader_pages()
	if _reader_page_index >= pages.size() - 1:
		return
	_stop_reader_voiceover()
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
	if READER_PRESENTATION.supports(_reader_note_id, pages):
		READER_PRESENTATION.render(_reader_body, _reader_note_id, _reader_page_index, str(pages[_reader_page_index]),
			{"mono": _reader_mono_font, "handprint": _reader_print_font, "handwritten": _reader_font})
	else:
		var source := str(pages[_reader_page_index])
		if str(_get_reader_presentation_style(_reader_note_id).get("body_font", "handwritten")) == "handwritten":
			_reader_body.clear()
			READER_INK.append(_reader_body, source, (_reader_note_id + str(_reader_page_index)).hash())
		else:
			_reader_body.text = source
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

func _play_reader_voiceover() -> void:
	_stop_reader_voiceover()
	if _reader == null || !is_instance_valid(_reader) || !_notes.has(_reader_note_id):
		return

	var voiceover_id := _get_note_voiceover_id(_reader_note_id, _notes[_reader_note_id])
	if voiceover_id.is_empty():
		return

	var audio_event = _lib.get_entry(_lib.Registry.SOUNDS, voiceover_id)
	if audio_event == null:
		_warn_voiceover_once(voiceover_id + ":missing_registry", "voiceover sound not registered: " + voiceover_id)
		return

	var player = AUDIO_INSTANCE_2D_SCENE.instantiate()
	player.name = "RtvLoreVoiceover"
	player.bus = VOICEOVER_AUDIO_BUS
	_reader.add_child(player)
	player.PlayInstance(audio_event)
	_active_voiceover_player = player

func _stop_reader_voiceover() -> void:
	if _active_voiceover_player != null && is_instance_valid(_active_voiceover_player):
		if _active_voiceover_player.has_method("stop"):
			_active_voiceover_player.stop()
		_active_voiceover_player.queue_free()
	_active_voiceover_player = null

func _close_reader() -> void:
	var had_reader := _reader && is_instance_valid(_reader)
	if get_viewport() != null && get_viewport().size_changed.is_connected(_resize_note_reader):
		get_viewport().size_changed.disconnect(_resize_note_reader)
	_stop_reader_voiceover()
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

func _request_close_reader() -> void:
	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()
	call_deferred("_close_reader")

func _reset_reader_interface_state(interface_node: Node) -> void:
	if interface_node == null || !is_instance_valid(interface_node):
		return

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
	_modal_previous_occupied = GAME_DATA.isOccupied
	GAME_DATA.freeze = true
	GAME_DATA.isOccupied = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	_modal_controls_active = true

func _release_modal_controls() -> void:
	if !_modal_controls_active:
		return

	GAME_DATA.freeze = _modal_previous_freeze
	GAME_DATA.isOccupied = _modal_previous_occupied
	Input.set_mouse_mode(_modal_previous_mouse_mode)
	_modal_controls_active = false
	_modal_previous_mouse_mode = Input.MOUSE_MODE_CAPTURED
	_modal_previous_freeze = false
	_modal_previous_occupied = false
