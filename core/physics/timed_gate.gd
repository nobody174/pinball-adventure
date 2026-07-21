#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends StaticBody2D

## Gate that's normally closed (blocks the ball) and opens on demand for a
## fixed duration, then closes again -- e.g. a "timed gate" unlocked by a
## target hit. Distinct from a one-way gate (which is always passable in
## one direction, no timer): this one is fully closed until triggered.

signal opened
signal closed

@export var open_duration_seconds: float = 1.5

var _is_open: bool = false
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _sprite: Polygon2D = $Sprite

func _ready() -> void:
	_update_visual()

func trigger_open() -> void:
	if _is_open:
		return
	_is_open = true
	_collision.set_deferred("disabled", true)
	_update_visual()
	opened.emit()
	await get_tree().create_timer(open_duration_seconds).timeout
	_is_open = false
	_collision.set_deferred("disabled", false)
	_update_visual()
	closed.emit()

func _update_visual() -> void:
	_sprite.color = Color(0.2, 1, 0.5, 0.5) if _is_open else Color(0.5, 0.5, 0.55, 1)

# Built with assistance from Claude Code by Anthropic.
