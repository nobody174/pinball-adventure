#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends RigidBody2D

## Placeholder flipper. One instance per flipper; `is_left` mirrors input/rotation direction.
## Tunable in the inspector for §10a feel-testing.
##
## Kinematically driven, not torque-based. A torque+PD controller plateaus:
## Godot's collision solver derives the ball's impulse from the flipper's
## actual measured velocity at the exact tick contact happens, which is
## capped by how far torque could accelerate it within one physics step —
## more torque past that ceiling doesn't help and just destabilizes. Driving
## rotation directly on a frozen/kinematic body gives the solver a known,
## full-strength contact-point velocity to transfer instead (see
## docs/inspiration/physics_notes.md for the research behind this).

@export var is_left: bool = true
## Positive = rotated clockwise on screen (Y-down). Rest droops the tip down
## and toward the pivot (reduces reach/overlap); active swings it up.
@export var rest_angle_degrees: float = 25.0
@export var active_angle_degrees: float = -35.0
@export var swing_duration_seconds: float = 0.15
@export var input_action: String = "flip_left"

var _rest_angle: float
var _active_angle: float
var _swing_t: float = 0.0 ## 0 = rest, 1 = fully active

func _ready() -> void:
	freeze = true
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	_rest_angle = deg_to_rad(rest_angle_degrees) * (1.0 if is_left else -1.0)
	_active_angle = deg_to_rad(active_angle_degrees) * (1.0 if is_left else -1.0)
	rotation = _rest_angle

func _physics_process(delta: float) -> void:
	var pressed := Input.is_action_pressed(input_action)
	var direction := 1.0 if pressed else -1.0
	_swing_t = clampf(_swing_t + direction * delta / swing_duration_seconds, 0.0, 1.0)
	## Ease-out (fast start) reads snappier than a linear ramp.
	var eased := 1.0 - pow(1.0 - _swing_t, 2.0)
	rotation = lerp_angle(_rest_angle, _active_angle, eased)

# Built with assistance from Claude Code by Anthropic.
