shader_type canvas_item;

uniform sampler2D imageTexture;
uniform sampler2D noiseTexture;
uniform float speed: hint_range (0.0,5.0);

void fragment(){
	COLOR = texture(imageTexture, UV);
	if (COLOR.r == COLOR.g && COLOR.r == COLOR.b)
	{
		float offset = sin(speed * TIME / 6.0) / (2.0 * TAU);
		vec2 noise_uv = (UV / 4.0) + vec2(0.5 + offset, 0.5 - offset);
		float noise_sample = texture(noiseTexture, noise_uv).r;
		COLOR.a = COLOR.a * noise_sample * noise_sample * noise_sample;
	}
}
