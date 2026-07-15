#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends StaticBody2D

## Bridge that's normally solid (ball rolls over it) and briefly collapses
## on trigger (ball falls through to whatever's underneath), then resets.
## Same disabled-collision mechanism as timed_gate.gd, but semantically
## distinct -- a bridge starts solid/passable-over and collapses, a gate
## starts closed/blocking and opens. Kept as separate scripts rather than
## one parameterized one so each table's intent stays obvious.

signal collapsed
signal reset

@export var collapse_duration_seconds: float = 2.0

var _is_collapsed: bool = false
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _sprite: Polygon2D = $Sprite

func _ready() -> void:
	_update_visual()

func trigger_collapse() -> void:
	if _is_collapsed:
		return
	_is_collapsed = true
	_collision.disabled = true
	_update_visual()
	collapsed.emit()
	await get_tree().create_timer(collapse_duration_seconds).timeout
	_is_collapsed = false
	_collision.disabled = false
	_update_visual()
	reset.emit()

func _update_visual() -> void:
	_sprite.color = Color(1, 0.3, 0.3, 0.35) if _is_collapsed else Color(0.5, 0.5, 0.55, 1)

# Built with assistance from Claude Code by Anthropic.
