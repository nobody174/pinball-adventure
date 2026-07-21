#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends Area2D

## One-way rollover lane: only reports a hit when the ball crosses it moving
## in one direction, not both. Distinct from standup_target.gd (which fires
## on any contact, any direction) -- a lane like "CPU Clock Cycle" should
## only score when the ball actually rolls through it forward, not when it
## rattles back out the way it came.
##
## Direction is evaluated in the node's own local rotation, not world space,
## so a rollover works the same regardless of which way it's placed/rotated
## on the table -- rotate the node in the editor to aim it, no extra config.

signal rolled_over(target_id: String)

@export var target_id: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body is PinballBall:
		return
	## Rotate the ball's world-space velocity into this node's local frame so
	## "moving forward through the lane" always means the same sign,
	## regardless of the rollover's own placement angle on the table.
	var ball := body as PinballBall
	var local_velocity: Vector2 = ball.linear_velocity.rotated(-global_rotation)
	if local_velocity.y < 0.0:
		rolled_over.emit(target_id)

# Built with assistance from Claude Code by Anthropic.
