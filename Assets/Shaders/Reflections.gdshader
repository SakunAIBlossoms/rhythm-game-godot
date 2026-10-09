shader_type canvas_item;

uniform vec2 TexSize = vec2(1280,720);
uniform float Strength = 0.0;
uniform float Scale = 0.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

const float threshold = 0.01;
const float maxSamples = 10.0;

void fragment()
{
	vec2 uv = FRAGCOORD.xy / TexSize;
	
	// Iterate until barely visible, caps at 20
	float samples = maxSamples;
	if (Strength != 1.0)
		float samples = min(floor(log(threshold)/ log(Strength)) + 1.0, maxSamples);
	vec2 toCenter = uv - vec2(0.5,0.5);
	
	// Initialise parameters
	vec3 color = vec3(0.0,0.0,0.0);
	vec2 scaleFactor = Scale + vec2(1.0,1.0);
	vec2 scale = vec2(1.0,1.0);
	float strength = 1.0;
	
	for (float i=0.0; i<samples; i++)
	{
		vec2 sampleUV = toCenter / scale + vec2(0.5,0.5);
		vec4 sampled = texture(SCREEN_TEXTURE, sampleUV);
		color += strength * sampled.w * sampled.xyz;
		scale *= scaleFactor;
		strength *= Strength;
	}
	
	COLOR = vec4(color,1.0);
}