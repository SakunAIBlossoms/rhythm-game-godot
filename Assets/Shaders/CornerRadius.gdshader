shader_type canvas_item;

uniform  vec2 size = vec2(90.0, 90.0);
uniform  float top = 50.0;
uniform  float right = 0.0;
uniform  float bottom = 0.0;
uniform  float left = 0.0;

bool isOut(float x, float y, float corner_scale) {
    return pow(x, 2.0) + pow(y, 2.0) > pow(corner_scale * 0.5, 2.0);
}

bool isTop(vec2 uv, float perc){
	float s = perc * 0.5;
	return uv.x < s && uv.y < s  && isOut(uv.x - s,  uv.y - s, perc);
}

bool isRight(vec2 uv, float perc){
	float s = perc * 0.5;
	return uv.x > 1.0 - s && uv.y < s && isOut(uv.x - 1.0 + s, uv.y - s, perc);
}

bool isBottom( vec2 uv, float perc){
	float s = perc * 0.5;
	return (
		uv.x > 1.0 - s && uv.y > 1.0 - s && 
		isOut(uv.x - 1.0 + s, uv.y - 1.0 + s, perc)
	);

}

bool isLeft(vec2 uv, float perc){
	float s = perc * 0.5;
	return uv.x < s && uv.y > 1.0 - s && isOut(uv.x - s, uv.y - 1.0 + s, perc);
	
}



void fragment() {
	
	float minSize 		= min(size.x, size.y) / 2.0;
	
	float topPerc 		= clamp(top / minSize, 0.0		, 2.0);
	float rightPerc 	= clamp(right / minSize, 0.0	, 2.0);
	float bottomPerc 	= clamp(bottom / minSize, 0.0	, 2.0);
	float leftPerc 		= clamp(left / minSize, 0.0		, 2.0);
	
    if (
		isTop(UV, topPerc) || isRight(UV, rightPerc) || 
		isBottom(UV, bottomPerc) || isLeft(UV, leftPerc)
	) {
        COLOR.a = 0.0;
	}else {
		COLOR = texture(TEXTURE, UV);
	}
	
}