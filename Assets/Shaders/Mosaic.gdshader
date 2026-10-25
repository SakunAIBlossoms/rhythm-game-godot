shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float strength : hint_range(0.0,1.0,0.01) = 0.0;

void fragment()
{
	vec2 uv = FRAGCOORD.xy / SCREEN_UV;
	float pixelSizeFactor = mix(1.0, min(uv.x, uv.y), 1.0 - strength);
	vec2 pixelSize = vec2(pixelSizeFactor, pixelSizeFactor * (uv.y / uv.x));
	vec2 pixelatedUV = (floor(SCREEN_UV * pixelSize) + 0.5) / pixelSize;
	if (strength > 0.0)
		COLOR = textureLod(SCREEN_TEXTURE, pixelatedUV, 0.0);
	else COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
}