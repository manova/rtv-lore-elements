# RTV-39 Reader Input Blocking

RTV-39 fixes the reader behaving visually like a modal while allowing mouse
hover, click, and scroll input to reach the inventory underneath.

## Modal root

Reader and journal overlays now share a full-viewport modal root `Control`.
The root uses `MOUSE_FILTER_STOP` and accepts `gui_input` events so empty
overlay space consumes mouse input before it can reach the inventory or
container UI behind the modal.

Because the modal root is parented directly under a `CanvasLayer`, it is sized
explicitly from the viewport instead of relying only on anchors. Without that
explicit size, the overlay can render while the hit-test rectangle remains too
small to block inventory input underneath.

Vanilla inventory hover and drag handling is not normal GUI propagation. It
runs in `Interface._physics_process()`, polls input state directly, and checks
item rectangles against the global mouse position. For that path, the modal
also sets `GameData.isOccupied` while open and restores the previous value on
close. Vanilla already treats that flag as an input blocker, hiding context and
highlight state and returning before hover, drag, transfer, or tooltip logic.

The dim `ColorRect` remains visual-only with `MOUSE_FILTER_IGNORE`. Interactive
children such as buttons and the reader body still receive their own events,
while non-interactive space bubbles to the modal root and is consumed there.

## Close behavior

Reader and journal close buttons route through small request helpers that mark
the viewport input as handled and defer the actual close. This keeps the mouse
release that closes the modal from being observed by UI underneath after the
modal is queued for removal.

Escape/settings close paths still use the existing topmost-overlay handling in
the input hooks and autoload fallback.

## Scope

This change does not alter reader layout, note content, journal persistence,
map pin rendering, loot, pricing, or localization. The journal receives the
same blocker pattern because it uses the same modal shape and can sit above the
inventory as well.
