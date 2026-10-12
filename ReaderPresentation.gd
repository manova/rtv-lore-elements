# Reader-only presentation of four accepted physical identities.
# No story rewriting or markup parsing: unexpected/localized pages use plain text.
extends RefCounted

const INK := preload("res://rtv-lore-elements/ReaderInk.gd")

const PAGE_HASHES := {
	"rtv_lore_schoolroom_list": ["043a7517946434aa69670449f7c7056f2793857148f560614b1f71576f002309", "af247bb73d96a1b7b8ce5f17952a0e323c4953eef9d0de0cf197504309fd82b8"],
	"rtv_lore_patrol_warning": ["16d3d01d4a4757c4711e339447056031e8d59ce01b2f73ac94d6971378e7a486", "80f7284805b2cb1d747f2aeb64c71689d599dae7e4f5598d465131918ba99d5d"],
	"rtv_lore_clinic_triage_card": ["f5b14f4bd336310be33c338198748e4ed4a3c795a1e2307cac9e8df00762988a", "95ab8dbd45e889d16c8c756f16589a56d4cf2c5de14b0a731af2d676e23ef400"],
	"rtv_lore_triage_unknown_male": ["d6c3d3361328a99da0558f63c55bc54f483d43a31c31e313e01abf388550b823", "e303e71a052649172b984d798734ca2ab6be31fc9507fbaee547bb3ca638e788"],
}
const HAND_INK := Color("293b55")
const PRINT_INK := Color("302a25")

static func supports(note_id: String, pages: Array) -> bool:
	if !PAGE_HASHES.has(note_id) || pages.size() != PAGE_HASHES[note_id].size():
		return false
	for index in range(pages.size()):
		if str(pages[index]).sha256_text() != PAGE_HASHES[note_id][index]:
			return false
	return true

static func style(note_id: String, base: Dictionary) -> Dictionary:
	var result := base.duplicate(true)
	result["rotation_degrees"] = 0.0
	result["portrait_reader"] = true
	result["margins"] = {"left": 36, "top": 42, "right": 36, "bottom": 22}
	result["canvas_size"] = [540, 760]
	result["decoration"] = "none"
	result["title_alignment"] = HORIZONTAL_ALIGNMENT_LEFT
	if note_id == "rtv_lore_schoolroom_list":
		result["ink_color"] = HAND_INK
		result["body_font"] = "handprint"
		result["body_font_size"] = 27
	elif note_id == "rtv_lore_patrol_warning":
		result["body_font_size"] = 21
	else:
		result["canvas_size"] = [500, 800]
		result["margins"] = {"left": 32, "top": 58, "right": 32, "bottom": 22}
		result["decoration"] = "triage_tag"
		result["body_font"] = "handprint"
		result["body_font_size"] = 24
		result["ink_color"] = HAND_INK
		result["title_alignment"] = HORIZONTAL_ALIGNMENT_CENTER
	return result

static func fit(wanted: Vector2, available: Vector2, portrait: bool) -> Vector2:
	if !portrait:
		return Vector2(minf(wanted.x, maxf(320, available.x)), minf(wanted.y, maxf(360, available.y)))
	var height := minf(wanted.y, maxf(360, available.y))
	# Preserve the physical ratio when space allows; retain a readable minimum
	# width for navigation/long words at the smallest supported viewport.
	var width := maxf(340, wanted.x * height / wanted.y)
	return Vector2(minf(width, maxf(320, available.x)), height)

static func text(note_id: String, page: int, source: String) -> String:
	if !PAGE_HASHES.has(note_id) || page < 0 || page >= PAGE_HASHES[note_id].size() || source.sha256_text() != PAGE_HASHES[note_id][page]:
		return source
	if note_id == "rtv_lore_schoolroom_list" && page == 0:
		for ending in ["scissors,", "sports mats,", "storage,", "science room,"]:
			source = source.replace(ending + " ", ending + "\n")
	elif note_id == "rtv_lore_patrol_warning":
		if page == 0:
			source = source.replace(". Do not ", ".\n\nDo not ")
		else:
			source = source.replace("withdraw. ", "withdraw.\n\n")
	elif note_id == "rtv_lore_clinic_triage_card":
		if page == 0:
			source = source.replace("unreadable. ", "unreadable.\n")
			source = source.replace("Exposure, ", "Exposure,\n")
			source = source.replace("hands, ", "hands,\n")
			source = source.replace("concussion. ", "concussion.\n\n")
		else:
			source = source.replace("available. ", "available.\n\n")
			source = source.replace("medicine. ", "medicine.\n\n")
	return source

static func render(body: RichTextLabel, note_id: String, page: int, source: String, fonts: Dictionary) -> void:
	body.clear()
	body.bbcode_enabled = false
	var display := text(note_id, page, source)
	if note_id not in ["rtv_lore_clinic_triage_card", "rtv_lore_triage_unknown_male"]:
		if note_id == "rtv_lore_schoolroom_list":
			INK.append(body, display, (note_id + str(page)).hash())
		else:
			body.add_text(display)
		return
	var lines := display.split("\n", true)
	var second_hand := false
	for index in range(lines.size()):
		var line: String = lines[index]
		var label := ""
		if line.begins_with("SCHOOL MEDICAL") || line == "[different hand:]":
			label = line
		else:
			for prefix in ["Name ", "Date:", "Patient:", "Age:", "Adm:", "Tx:", "Att.:", "Morning note:"]:
				if line.begins_with(prefix):
					label = prefix
		if !label.is_empty():
			add_run(body, label, fonts.get("mono"), 18, PRINT_INK)
		var remaining := line.substr(label.length())
		add_run(body, remaining, fonts.get("handwritten") if second_hand else fonts.get("handprint"), 26 if second_hand else 24, HAND_INK, true, (note_id + str(page) + str(index)).hash())
		if line == "[different hand:]": second_hand = true
		if index < lines.size() - 1: body.add_text("\n")

static func add_run(body: RichTextLabel, value: String, font: Font, size: int, ink: Color, handwritten := false, seed_ := 0) -> void:
	if value.is_empty(): return
	body.push_color(ink)
	if font != null: body.push_font(font, size)
	else: body.push_font_size(size)
	if handwritten: INK.append(body, value, seed_)
	else: body.add_text(value)
	body.pop()
	body.pop()
