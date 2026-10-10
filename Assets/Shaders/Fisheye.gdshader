shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float Strength = 0.0;

vec2 FishEyeUV(vec2 uv)
{
    vec2 center = vec2(0.5);
    float corner = length(center);
    vec2 d = uv - 0.5;
    float r = length(d);

    if (Strength > 0.0)
    {
        float fac = Strength * PI * 0.5;
        uv = vec2(0.5) + normalize(d) * tan(r * fac) * corner / tan(corner * fac);
    }
    else
    {
        float fac = tan(Strength) * PI * 2.0;
        uv = vec2(0.5) + normalize(d) * atan(r * -fac) * 0.5 / atan (0.5 * -fac);
    }
    return uv;
}

void fragment() 
{
	vec2 uv = SCREEN_UV;
	
	vec4 colour = texture(SCREEN_TEXTURE, FishEyeUV(uv));
	
	COLOR = colour;
}