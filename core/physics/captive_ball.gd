#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends RigidBody2D

## A ball confined to a short lane, struck by the main ball to score (real
## captive-ball mechanic). Deliberately does not reuse ball.gd -- no
## drain/respawn/launch/nudge logic applies here, containment comes purely
## from the lane's own wall geometry set up by the table, same as any
## other static playfield boundary. This script's only job is detecting a
## strike from the real ball and reporting it.

signal struck(target_id: String)

@export var target_id: String = ""
@export var restitution: float = 0.7
@export var friction: float = 0.1

func _ready() -> void:
	var mat := PhysicsMaterial.new()
	mat.bounce = restitution
	mat.friction = friction
	physics_material_override = mat
	contact_monitor = true
	max_contacts_reported = 2
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D and body != self:
		struck.emit(target_id)

# Built with assistance from Claude Code by Anthropic.
