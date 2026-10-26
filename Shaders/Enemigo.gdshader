shader_type canvas_item;

uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float gray_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 gray_color : source_color = vec4(0.45, 0.45, 0.45, 1.0);

void fragment() {
	// Gris (muerte): se mezcla hacia un color fijo, igual que el flash
	COLOR.rgb = mix(COLOR.rgb, gray_color.rgb, gray_amount);

	// Flash (daño): va encima, así sigue viéndose blanco aunque ya esté gris
	COLOR.rgb = mix(COLOR.rgb, flash_color.rgb, flash_amount);
}