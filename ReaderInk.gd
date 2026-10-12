# Reader-only pen treatment. Text remains shaped, selectable and localizable.
extends RichTextEffect

var bbcode := "rtv_pen"

static func pen_font(base: Font) -> Font:
	var pen := FontVariation.new()
	pen.base_font = base
	# Slightly finer Caveat strokes, not a replacement for its letterforms.
	pen.variation_embolden = -0.12
	return pen

static func compatible(value: String) -> bool:
	# Do not disturb connected scripts or combining marks in localized text.
	# Those still use the ordinary font/fallback shaping and exact source text.
	for character in value:
		var code := character.unicode_at(0)
		var punctuation := (code >= 0x2000 && code <= 0x200a) || (code >= 0x2010 && code <= 0x2027)
		if code > 0x024f && !punctuation && code != 0x20ac:
			return false
	return true

static func pressure(seed_: int, index: int) -> Vector2:
	# Fixed source position, not elapsed time, frame, RNG or viewport coordinates.
	var bits := ((seed_ & 0x7fffffff) ^ (index * 1103515245 + 12345)) & 0x7fffffff
	var fine := float(bits % 997) / 996.0
	var drift := sin(float(index) * 0.19 + float(seed_ % 97))
	return Vector2(0.4 * drift + 0.18 * (fine - 0.5), 0.94 + 0.06 * fine)

func _process_custom_fx(glyph: CharFXTransform) -> bool:
	var sample := pressure(int(glyph.env.get("seed", 0)), glyph.relative_index)
	glyph.offset.y += sample.x
	glyph.color.a *= sample.y
	return true

static func append(body: RichTextLabel, value: String, seed_: int) -> void:
	if value.is_empty(): return
	if !compatible(value):
		body.add_text(value)
		return
	# Keep effects inside a paragraph: Godot's selection range can truncate when
	# a custom-effect item spans paragraph breaks. Newlines stay ordinary text.
	# Printed labels, titles, navigation and journal controls never enter a run.
	var lines := value.split("\n", true)
	for index in range(lines.size()):
		if !lines[index].is_empty():
			body.push_customfx(load("res://rtv-lore-elements/ReaderInk.gd").new(), {"seed": seed_ + index})
			body.add_text(lines[index])
			body.pop()
		if index < lines.size() - 1: body.add_text("\n")
