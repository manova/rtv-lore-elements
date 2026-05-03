# RTV-36 Pinned-Location Discovery

## Vanilla map surface

Road to Vostok does not expose a dedicated map-marker autoload or public marker API. The clean surface is the existing map UI:

- `res://Scripts/Interface.gd` owns the tool tab flow. Pressing the map tool calls `Interface._on_map_pressed()`, which hides other tools, shows `$Tools/Map`, calls `Map()`, then `FocusMap()`.
- `res://UI/Interface.tscn` instantiates `res://UI/Elements/Map.tscn` at `Tools/Map/Elements/Navigator/Scroll/Map`.
- `res://Scripts/MapTool.gd` is attached to `Tools/Map/Elements/Navigator/Scroll`, a `ScrollContainer`. Its first child is the `TextureRect` map. It pans by changing scroll offsets and zooms by scaling that child.
- `res://UI/Elements/Map.tscn` already stores map-pixel `Marker2D` nodes named `Village`, `Highway`, `School`, `Outpost`, `Island`, and `Minefield`. `MapTool.Focus(marker)` uses those marker child positions to center the map.

RTV-36 attaches a non-interactive `Control` named `RtvLorePinLayer` above the `Scroll` viewport and recalculates marker screen positions from `map_pixel * zoom - scroll_offset`. This avoids scene replacement, avoids a new save path, and keeps marker dot/label size readable while the map zooms.

## Better Maps coexistence

Andrew's install contains `C:/Program Files (x86)/Steam/steamapps/common/Road to Vostok/mods/bettermaps.zip`, mounted by Metro as `bettermaps.zip`. Its manifest registers:

- mod id: `bettermaps`
- autoload: `MapSwapper -> res://mods/bettermaps/MapSwapper.gd`

`MapSwapper.gd` uses the same vanilla map surface. It listens to `get_tree().node_added`, waits for an `Interface` node, finds `Tools/Map/Elements/Navigator/Scroll`, takes child `0` as the map `TextureRect`, and adds an `overlay_texture_rect` child to it. During `_process`, it swaps the base map texture and optional overlay texture according to MCM values.

Better Maps MCM uses:

- MCM id: `BetterMaps`
- config path: `user://MCM/BetterMaps/config.ini`
- keys: `map_type`, `map_style`, `map_overlay`, `map_overlay_opacity`, `tac_type`, `tac_style`, `tac_overlay`, `tac_overlay_opacity`

Lore Elements does not call into Better Maps, read its config, or depend on its nodes. Better Maps attaches its overlay under the map texture; Lore Elements attaches `RtvLorePinLayer` above the scroll viewport with a distinct node name and high `z_index`. That keeps pins above Better Maps' overlay child when Better Maps is loaded, while still working on vanilla maps.

## Better Maps install diagnosis

The latest local logs show Better Maps is installed, mounted, and registered:

- `modloader_filescope.log` reports `EXISTS` and `MOUNTED` for `bettermaps.zip`.
- `modloader_conflicts.txt` lists Better Maps at load order slot 3 with priority `0`.
- `godot.log` shows `Autoload queued: MapSwapper -> res://mods/bettermaps/MapSwapper.gd`.
- `godot.log` shows `[MCM] BetterMaps has been successfully registered`.

There is one Better Maps warning: `[MCM] BetterMaps has failed to register. This ID already exists.` Its source calls `helpers.RegisterConfiguration(...)` twice, so the second call is rejected. The first registration succeeds and the config file exists, so this warning does not by itself prove the mod is inactive.

Smoke-test MCM values selected Full Map for both normal and tactical maps. Better Maps ships only one Full Map style file, so Style 2 is clamped back to Style 1 and should not be expected to visibly change. In one test config the tactical overlay value was also beyond the shipped Full Map overlay count, which resolves to no overlay. If the in-game map still appears unchanged, the most likely quick checks are:

- Confirm a Map or Map (Tactical) item is equipped; vanilla hides the map surface without a map item.
- Set an obvious Better Maps combination in MCM, such as Normal Map = Area 05, Style 4, Overlay 1 at opacity `1.0`, save, close and reopen the map tab.
- If testing a tactical map, adjust the `tac_*` settings rather than the normal `map_*` settings.

## RTV-36 implementation decision

Green light. The pin layer can coexist with Better Maps because both attach to the vanilla map texture, and Lore Elements can render above Better Maps without importing or patching Better Maps. RTV-36 treats `pinned_location.x/y` as map-pixel coordinates on the 3840x2160 map texture. `z` and `scene_id` are accepted as reserved metadata for future world-space or scene-filtered pin work.

## Smoke result

A local smoke build temporarily pinned `rtv_lore_evacuation_notice` to the Outpost marker coordinate. In-game testing confirmed that the marker renders on the map, remains fixed while zooming, and stays readable after switching to the viewport-overlay positioning model. Earlier child-node approaches either moved relative to the Outpost label during zoom or became too small at starting zoom, so the final implementation keeps the marker in screen space and scales it modestly with map zoom.
