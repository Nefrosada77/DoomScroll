shader_type canvas_item;

uniform int state : hint_enum("Calm", "Warning", "Combat");
uniform vec3 calm_color : source_color;
uniform vec3 warning_color : source_color;
uniform vec3 combat_color : source_color;
uniform float circle_size : hint_range(0.0, 0.6, 0.05) = 0.45;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float circle = distance(UV, vec2(0.5));
	COLOR.a = step(circle, circle_size);
	if (COLOR.rgb == vec3(1.,1.,1.)){
		if (state == 0){
			COLOR.rgb = calm_color;
		} 
		if (state == 1){
			COLOR.rgb = warning_color;
		}
		if (state == 2)
			COLOR.rgb = combat_color;
		}
	}