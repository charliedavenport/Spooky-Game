shader_type canvas_item;

uniform sampler2D mask_texture;

void fragment() {
	COLOR = texture(TEXTURE, UV);
}
