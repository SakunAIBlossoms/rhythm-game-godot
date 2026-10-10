shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float Amount = 0.0;
uniform float Speed = 0.0;

highp float random(highp vec2 st)
{
    return fract(sin(dot(st.xy, vec2(12.9898, 4.1414))) * 43758.5453123);
}

highp float randomRange(highp vec2 st, float min, float max)
{
    return min + random(st) * (max - min);
}

highp float insideRange(float v, float b, float t)
{
    return step(b, v) - step(t, v);
}

void fragment() {
	vec4 colour = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	float maxOff = Amount / 2.0;
	float time = floor(TIME * Speed * 60.0);
	
	for (float i = 0.0; i < 10.0 * Amount; i++)
	{
		float slcY = random(vec2(time, 2345.0 * float(i)));
		float slcH = random(vec2(time, 9035.0 * float(i))) * 0.25;
		float hOff = randomRange(vec2(time, 9625.0 + float(i)), -maxOff, maxOff);
		
		vec2 uvOff = SCREEN_UV;
		uvOff.x += hOff;
		
		if (insideRange(SCREEN_UV.y, slcY, fract(slcY + slcH)) == 1.0) {
			colour = texture(SCREEN_TEXTURE, uvOff);
		}
	}
	
	float maxColOff = Amount / 6.0;
	float rnd = random(vec2(time, 9545.0));
	vec2 colOffset = vec2(
		randomRange(vec2(time, 9545.0), -maxColOff, maxColOff),
		randomRange(vec2(time, 7205.0), -maxColOff, maxColOff)
	);
	
	if (rnd < 0.33) {
		colour.r = texture(SCREEN_TEXTURE, SCREEN_UV + colOffset).r;
	} else if (rnd < 0.66) {
		colour.g = texture(SCREEN_TEXTURE, SCREEN_UV + colOffset).g;
    } else {
		colour.b = texture(SCREEN_TEXTURE, SCREEN_UV + colOffset).b;  
    }
	
	COLOR = colour;
}