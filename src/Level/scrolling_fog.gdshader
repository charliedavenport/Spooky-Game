shader_type canvas_item;

uniform sampler2D noise_tex2: repeat_enable;

uniform sampler2D gradient_tex;

uniform vec2 scroll1 = vec2(0.03, 0.03);
uniform vec2 scroll2 = vec2(-0.03, -0.03); 

uniform vec2 world_pos;
uniform vec2 tex_size;

void fragment() {
	
	vec2 world_offset = vec2(world_pos.x / tex_size.x, world_pos.y / tex_size.y);
	
	float texColor1 = texture(TEXTURE, UV + world_offset + scroll1 * TIME).r;
	float texColor2 = texture(noise_tex2, UV + world_offset + scroll2 * TIME).r;
	float energy = (texColor1 + texColor2) / 2.0;
	vec4 finalColor = texture(gradient_tex, vec2(energy));
	COLOR = finalColor;
}
