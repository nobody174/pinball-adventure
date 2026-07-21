#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends StaticBody2D

## Spike 10c probe: a "Broken Ramp"-style wall that flips solid/intangible on
## a fixed timer, deliberately toggling *while a ball is likely mid-contact*
## (short period relative to ball speed) rather than only on a safe idle
## timer -- that's the actual failure mode this spike exists to catch.
## Every toggle goes through set_deferred, per the hard rule established
## this session (collapsing_bridge.gd / timed_gate.gd fixes).

@export var phase_period_seconds: float = 0.6
@export var start_solid: bool = true

var _is_solid: bool
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _sprite: Polygon2D = $Sprite

func _ready() -> void:
	_is_solid = start_solid
	_apply_state()
	var timer := Timer.new()
	timer.wait_time = phase_period_seconds
	timer.autostart = true
	timer.timeout.connect(_toggle)
	add_child(timer)

func _toggle() -> void:
	_is_solid = not _is_solid
	_apply_state()

func _apply_state() -> void:
	_collision.set_deferred("disabled", not _is_solid)
	_sprite.color = Color(0.5, 0.5, 0.55, 1) if _is_solid else Color(1, 0.3, 0.3, 0.35)

# Built with assistance from Claude Code by Anthropic.
