#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends Area2D

## Reusable rotating table toy: spins continuously, can be toggled "charged"
## externally (e.g. by an objective completing), and reports which state the
## ball hit it in. What "charged" means to a given table, and what happens
## on each kind of hit, is entirely up to that table — this script only
## knows spin + color + report.
##
## Also tracks up to 3 named "gate" flags (modeled on a reference Godot
## pinball project's central rotating toy, which gates a wizard-mode
## multiball behind raising 3 gates) -- a table can raise/check them without
## this script knowing what completing each one means. Distinct from the
## charged/uncharged state: gates accumulate progress toward something
## bigger (e.g. a wizard-mode readiness check), charged/uncharged is the
## toy's own moment-to-moment hit state.

signal hit_while_charged
signal hit_while_uncharged
signal gate_raised(gate_index: int)
signal all_gates_raised

@export var rotation_speed: float = 1.5 ## radians/sec, idle speed.
@export var overload_rotation_speed: float = 6.0 ## Speed once all gates are raised -- a visible "it's ready" tell.
@export var charged_color: Color = Color(0.2, 1, 0.5, 1)
@export var uncharged_color: Color = Color(1, 0.2, 0.3, 1)

var charged: bool = false:
	set(value):
		charged = value
		_update_color()

var _gates_raised: Array[bool] = [false, false, false]

@onready var _sprite: Polygon2D = $Sprite

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_color()

func _process(delta: float) -> void:
	var speed := overload_rotation_speed if are_all_gates_raised() else rotation_speed
	rotation += speed * delta

func _on_body_entered(body: Node2D) -> void:
	if not body is PinballBall:
		return
	if charged:
		hit_while_charged.emit()
	else:
		hit_while_uncharged.emit()

## gate_index is 0, 1, or 2 -- which of the 3 tracked gates to raise. What
## real-world objective maps to which index is entirely up to the table.
func raise_gate(gate_index: int) -> void:
	if gate_index < 0 or gate_index >= _gates_raised.size() or _gates_raised[gate_index]:
		return
	_gates_raised[gate_index] = true
	gate_raised.emit(gate_index)
	if are_all_gates_raised():
		all_gates_raised.emit()

func are_all_gates_raised() -> bool:
	return not _gates_raised.has(false)

## Resets all 3 gates, e.g. after cashing in the reward they were gating.
func reset_gates() -> void:
	_gates_raised = [false, false, false]

func _update_color() -> void:
	_sprite.color = charged_color if charged else uncharged_color

# Built with assistance from Claude Code by Anthropic.
