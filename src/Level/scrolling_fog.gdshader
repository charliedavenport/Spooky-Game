shader_type canvas_item;

uniform sampler2D noise_tex2;

uniform sampler2D gradient_tex;

uniform vec2 scroll1 = vec2(0.03, 0.03);
uniform vec2 scroll2 = vec2(-0.03, -0.03); 

uniform vec2 positionOffset = vec2(0.0, 0.0);

void fragment() {
	float texColor1 = texture(TEXTURE, UV + positionOffset + scroll1 * TIME).r;
	float texColor2 = texture(noise_tex2, UV + positionOffset + scroll2 * TIME).r;
	float energy = (texColor1 + texColor2) / 2.0;
	vec4 finalColor = texture(gradient_tex, vec2(energy));
	COLOR = finalColor;
}
