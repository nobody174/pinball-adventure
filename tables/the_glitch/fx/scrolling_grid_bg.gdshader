shader_type canvas_item;

// Animated scrolling grid background — cheap (no texture sampling, just
// procedural lines). Confirmed steady 60fps on real mobile hardware (§10b
// performance spike, see docs/PROGRESS.md) before being adopted here.

uniform vec4 grid_color : source_color = vec4(0.2, 0.9, 1.0, 0.5);
uniform vec4 bg_color : source_color = vec4(0.03, 0.04, 0.08, 1.0);
uniform float scroll_speed : hint_range(0.0, 2.0) = 0.15;
uniform float grid_scale : hint_range(4.0, 64.0) = 20.0;

void fragment() {
	vec2 uv = UV;
	uv.y += TIME * scroll_speed;
	vec2 grid_uv = fract(uv * grid_scale);
	float line_x = smoothstep(0.0, 0.04, grid_uv.x) * smoothstep(0.0, 0.04, 1.0 - grid_uv.x);
	float line_y = smoothstep(0.0, 0.04, grid_uv.y) * smoothstep(0.0, 0.04, 1.0 - grid_uv.y);
	float line = 1.0 - min(line_x, line_y);
	COLOR = mix(bg_color, grid_color, line);
}
