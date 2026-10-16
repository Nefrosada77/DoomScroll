shader_type spatial;

global uniform vec3 level_color;
uniform float circle_size : hint_range(0.0, 0.6, 0.05) = 0.45;
uniform float brightness : hint_range(0.0, 1.0, 0.01) = 0.2;

void fragment() {
	ALBEDO.rgb = level_color;
	float circle = distance(UV, vec2(0.5));
	ALPHA = (step(circle_size, circle) + 0.75) * ((abs(sin(TIME))*(brightness)+0.15)*circle);
}
