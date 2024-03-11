shader_type canvas_item;

uniform sampler2D noiseX;
uniform sampler2D noiseY;

vec2 random(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
}

float worley(vec2 uv, float columns, float rows) {
	
	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));
	
	float minimum_dist = 1.0;  
	
	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random(index_uv + neighbor);
			
			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);
			minimum_dist = min(minimum_dist, dist);
		}
	}
	
	return minimum_dist;
}

void fragment() {
	float x = texture(noiseX, UV).g;
	float y = texture(noiseY, UV).g;
	float angle = TIME / 6.0 - float(int(TIME / 6.0)) * TAU;
	float dx = cos(angle);
	float dy = sin(angle);
	vec2 samplePos = vec2(x, y) / 2.0 + vec2(dx, dy) / 4.0 + vec2(0.25, 0.25);
	float worleyOuter = worley(samplePos, 4.0, 4.0);
	float worleyInner = worley(samplePos, 40.0, 40.0);
	float v = worleyOuter * worleyOuter * worleyInner;
	COLOR = vec4(vec3(0, 0.2 - v / 5.0, v/5.0), 1.0);
}
