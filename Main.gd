# Lore Elements — Main autoload entry point.
# See PLANNING.md for project context, architecture, and phased roadmap.
extends Node

var _lib = null

func _ready() -> void:
    if Engine.has_meta("RTVModLib"):
        var lib = Engine.get_meta("RTVModLib")
        if lib._is_ready:
            _on_lib_ready()
        else:
            lib.frameworks_ready.connect(_on_lib_ready)
    else:
        push_warning("[rtv_lore_elements] RTVModLib meta not present — Metro Mod Loader required.")

func _on_lib_ready() -> void:
    _lib = Engine.get_meta("RTVModLib")
    print("[rtv_lore_elements] frameworks ready, registering...")
    # Register lore items here in Phase 1
    # _register_lore_items()
    # _register_lore_loot()
    # _register_keybinds()
    pass
