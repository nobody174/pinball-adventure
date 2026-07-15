#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends Area2D

## Sets the ball's collision_mask on entry -- the trick two ramps need to
## physically cross each other in flat 2D without colliding at the
## crossing point. Each ramp's own walls live on their own dedicated
## physics layer (NOT the default layer), so a ball only collides with a
## given ramp's walls while its mask includes that ramp's bit. Placed at
## each ramp's entrance (mask = default | this_ramp_bit) and exit
## (mask = default, dropping the bit again). The trigger area itself stays
## on the default layer so it can detect the ball regardless of the ball's
## current custom mask.

signal entered(target_id: String)

@export var target_id: String = ""
@export var target_collision_mask: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		body.collision_mask = target_collision_mask
		entered.emit(target_id)

# Built with assistance from Claude Code by Anthropic.
