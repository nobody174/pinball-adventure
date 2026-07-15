#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends Area2D

## Generic standup target: flashes on contact and reports its own id to
## whatever's listening. What that id means (part of a sequence, a bonus,
## etc.) is entirely up to the table/objective config, not this script.

signal hit(target_id: String)

@export var target_id: String = ""
@export var flash_color: Color = Color(1, 1, 1, 1)

## CanvasItem, not Polygon2D -- $Sprite can be either a flat placeholder
## shape or a baked-texture Sprite2D depending on the table's art pass;
## modulate works identically on both since it's a CanvasItem property,
## unlike Polygon2D's own .color.
@onready var _sprite: CanvasItem = $Sprite

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body is RigidBody2D:
		return
	hit.emit(target_id)
	flash(flash_color)

## Public so the table can trigger feedback (e.g. a red flash on the whole
## group when a sequence resets) without that being tangled into this node's
## own hit-detection logic.
func flash(color: Color, duration: float = 0.15) -> void:
	_sprite.modulate = color
	await get_tree().create_timer(duration).timeout
	_sprite.modulate = Color.WHITE

# Built with assistance from Claude Code by Anthropic.
