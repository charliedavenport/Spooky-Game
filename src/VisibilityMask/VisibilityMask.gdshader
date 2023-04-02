shader_type canvas_item;

uniform bool true_sight = false;

void fragment() {
	float alpha = float(!true_sight);
	COLOR = vec4(1,1,1,alpha);
}
