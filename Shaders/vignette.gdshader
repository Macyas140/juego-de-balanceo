shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.5) = 0.0;
uniform float radius : hint_range(0.0, 1.5) = 0.75;
uniform float softness : hint_range(0.0, 2.0) = 0.5;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	float vignette = smoothstep(radius, radius - softness, dist);
	COLOR = vec4(0.0, 0.0, 0.0, strength * (1.0 - vignette));
}
