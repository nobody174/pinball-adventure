#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends Node2D

## Procedural jagged lightning-bolt effect: a random angle is chosen once,
## then every frame redraws a jagged polyline of fixed-length segments along
## that angle with small random jitter, giving a flickering "electric arc"
## look with no shader or sprite sheet needed. Self-frees after
## lifetime_seconds via the sibling Timer -- spawn one, forget it.
##
## Cheap by construction (a handful of draw_polyline calls), so it's a
## reasonable choice for a "corruption surge" burst around the Glitch Core
## without touching the table's frame-time budget the way stacking more
## particle emitters or shader passes would.

const POINT_STEP := Vector2(24, 0) ## Length of one jagged segment.
const SEGMENT_COUNT := 9

@export var glow_color: Color = Color(1, 0.2, 0.6, 0.5)
@export var core_color: Color = Color(1, 0.9, 1.0, 1.0)
@export var lifetime_seconds: float = 0.5

var _rng := RandomNumberGenerator.new()
var _base_angle: float
var _points: PackedVector2Array

func _ready() -> void:
	_rng.randomize()
	_base_angle = _rng.randf_range(0.0, TAU)
	$Timer.wait_time = lifetime_seconds
	$Timer.timeout.connect(queue_free)
	$Timer.start()

func _process(_delta: float) -> void:
	_points = PackedVector2Array()
	var prior_point := Vector2.ZERO
	for segment_index in range(1, SEGMENT_COUNT):
		_points.append(prior_point)
		var jittered_angle := _base_angle + _rng.randf_range(0.0, 0.2)
		var point: Vector2 = POINT_STEP.rotated(jittered_angle) * segment_index
		_points.append(point)
		prior_point = point
	queue_redraw()

func _draw() -> void:
	if _points.is_empty():
		return
	draw_polyline(_points, glow_color, 8.0)
	draw_polyline(_points, core_color, 2.0)

# Built with assistance from Claude Code by Anthropic.
