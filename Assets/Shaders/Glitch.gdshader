// https://github.com/InventiveRhythm/fluXis/blob/main/fluXis.Resources/Shaders/sh_Glitch.fs
shader_type canvas_item;

uniform float StrengthX = 0.0;
uniform float StrengthY = 0.0;
uniform float BlockSize = 0.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

highp float random(highp vec2 st, float seed)
{
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233) + seed)) * 43758.5453123);
}

void fragment() {
	vec2 Strength = vec2(StrengthX / 10.0, StrengthY / 10.0);
	
	vec2 uv = SCREEN_UV;
	
	float blockSizeInPixels = mix(1.0, min(1280.0, 720.0), BlockSize);
	
	vec2 blockUV = floor(uv * blockSizeInPixels) / blockSizeInPixels;
	
	float randomShiftX = (random(blockUV, TIME / 1000.0) - 0.5) * Strength.x;
	float randomShiftY = (random(blockUV + vec2(5.0), TIME / 1000.0) - 0.5) * Strength.y;
	
	vec2 fixedUV = uv;
	fixedUV.x += randomShiftX;
	fixedUV.y += randomShiftY;
	
	vec4 pixelColor = textureLod(SCREEN_TEXTURE, fixedUV, 0.0);
	
	COLOR = pixelColor;
}
