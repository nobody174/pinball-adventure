#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends Area2D

## Subway tunnel entrance: ball entering here reappears at exit_point with
## exit_velocity. Built on ball.gd's request_teleport(), which already
## disables CCD around the jump -- a naive direct-transform teleport here
## would hit the exact bogus-sweep-collision bug that fix was built for
## (see ball.gd's own comments), so this deliberately does not reimplement
## teleportation itself.

signal entered(target_id: String)

@export var target_id: String = ""
@export var exit_point: NodePath
@export var exit_velocity: Vector2 = Vector2(0, 400)

@onready var _exit_node: Node2D = get_node(exit_point)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body is RigidBody2D or not body.has_method("request_teleport"):
		return
	entered.emit(target_id)
	body.request_teleport(_exit_node.global_position, exit_velocity)

# Built with assistance from Claude Code by Anthropic.
