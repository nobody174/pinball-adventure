shader_type canvas_item;

// Screen-space RGB-split "glitch" distortion, GL Compatibility-safe (no
// compute/SSR dependency, just a SCREEN_TEXTURE read — that read itself is
// one of the risky/expensive things §10b exists to measure).

uniform float glitch_strength : hint_range(0.0, 0.02) = 0.006;
uniform float line_count : hint_range(10.0, 200.0) = 60.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float rand(float x) {
	return fract(sin(x * 12.9898) * 43758.5453);
}

void fragment() {
	float line = floor(SCREEN_UV.y * line_count);
	float jitter = (rand(line + floor(TIME * 8.0)) - 0.5) * glitch_strength;
	vec2 uv_r = SCREEN_UV + vec2(jitter, 0.0);
	vec2 uv_b = SCREEN_UV - vec2(jitter, 0.0);
	float r = texture(SCREEN_TEXTURE, uv_r).r;
	float g = texture(SCREEN_TEXTURE, SCREEN_UV).g;
	float b = texture(SCREEN_TEXTURE, uv_b).b;
	COLOR = vec4(r, g, b, 1.0);
}
