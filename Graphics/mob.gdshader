shader_type canvas_item;

uniform float mutatorA;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (mutatorA > 0.0)
	{
		if (COLOR.a > 0.0)
		{
			float v = abs(sin(TIME * mutatorA * mutatorA * 2.0));
			COLOR.r = mix(COLOR.r, 1, v);
		}
	}
}
