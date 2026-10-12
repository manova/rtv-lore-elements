shader_type canvas_item;

// These icons already contain the reviewed world lighting and tone mapping.
// Preserve their RGBA instead of applying the native item's extra exposure.
void fragment() {
	COLOR = texture(TEXTURE, UV);
}
