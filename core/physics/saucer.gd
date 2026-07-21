#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends Area2D

## Generic saucer/kickout hole: captures the ball on contact (freezes it in
## place), holds it briefly, then ejects it with an impulse. Distinct from
## every other trigger in core/physics/ (standup_target, spinner, bumper)
## in that it actually takes control of the ball for a moment rather than
## just reacting to a pass-through -- what the hold looks/sounds like and
## what "captured" scores is entirely up to the table.

signal captured(target_id: String)
signal ejected(target_id: String)

@export var target_id: String = ""
@export var hold_duration_seconds: float = 0.6
@export var eject_direction: Vector2 = Vector2.UP
@export var eject_strength: float = 400.0

var _holding: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	## Must check for the ball specifically, not just any RigidBody2D --
	## flippers are RigidBody2D too (kinematically driven), and a ball can
	## physically knock one into a saucer's trigger area. Freezing/ejecting
	## a flipper this way silently detaches it from its pivot for good.
	if not body is PinballBall or _holding:
		return
	_holding = true
	captured.emit(target_id)
	body.set_deferred("freeze", true)
	body.linear_velocity = Vector2.ZERO
	body.global_position = global_position
	await get_tree().create_timer(hold_duration_seconds).timeout
	body.freeze = false
	body.apply_central_impulse(eject_direction.normalized() * eject_strength)
	ejected.emit(target_id)
	_holding = false

# Built with assistance from Claude Code by Anthropic.
