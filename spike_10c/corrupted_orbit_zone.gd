#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends Area2D

## Spike 10c probe: "Corrupted Orbit" -- on entry, either reverses the ball's
## velocity in place or teleports it to exit_position with exit_velocity,
## chosen at random each hit. Reuses ball.gd's request_teleport() (already
## proven CCD-safe from the debug-teleport work earlier this session)
## rather than reimplementing teleport handling here.

@export var exit_position: Vector2
@export var exit_velocity: Vector2 = Vector2(0, -600)
@export var cooldown_seconds: float = 0.3

var _cooldown_remaining: float = 0.0

func _physics_process(delta: float) -> void:
	_cooldown_remaining = maxf(0.0, _cooldown_remaining - delta)

func _on_body_entered(body: Node2D) -> void:
	if _cooldown_remaining > 0.0:
		return
	_cooldown_remaining = cooldown_seconds
	if not body.has_method("request_teleport"):
		return
	if randf() < 0.5:
		body.request_teleport(body.global_position, -body.linear_velocity)
	else:
		body.request_teleport(exit_position, exit_velocity)

# Built with assistance from Claude Code by Anthropic.
