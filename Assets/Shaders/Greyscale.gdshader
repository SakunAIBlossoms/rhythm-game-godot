shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float Strength : hint_range(0.0,1.0) = 0.0;

void fragment() {
	vec4 colour = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	float grey = dot(colour.rgb, vec3(0.299, 0.587, 0.114));
	vec3 greyColour = vec3(grey, grey, grey);
	
	COLOR = mix(colour, vec4(greyColour, colour.a), Strength);
}