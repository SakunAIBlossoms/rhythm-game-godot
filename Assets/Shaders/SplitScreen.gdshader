shader_type canvas_item;

uniform vec2 SplitInv = vec2(0,0);
uniform float Strength = 0.0;
uniform int SplitsX = 0;
uniform int SplitsY = 0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 quad = trunc(uv*vec2(float(SplitsX), float(SplitsY)));
	
	vec2 zoom = mix(vec2(1.0), SplitInv, vec2(Strength));
	vec2 offset = mix(vec2(0.0), quad * SplitInv, vec2(Strength));
	
	vec2 uvQuad = (uv - offset) / zoom;
	vec4 colour = texture(SCREEN_TEXTURE, uvQuad);
	
	COLOR = colour;
	
}