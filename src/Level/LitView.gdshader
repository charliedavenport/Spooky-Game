shader_type canvas_item;

uniform sampler2D mask_texture;
uniform bool true_sight = false;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 mask = texture(mask_texture, UV);
	color.a = 1.0 - (mask.r * float(!true_sight));
	COLOR = color;
}