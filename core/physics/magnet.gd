#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends Area2D

## Playfield magnet: pulls the ball toward its center while active. Not
## always-on -- real playfield magnets are cued (by a target hit, a timer,
## etc.), so activation is externally driven via activate()/deactivate()
## rather than this script deciding when to fire.

signal activated
signal deactivated

@export var pull_strength: float = 300.0
@export var active_duration_seconds: float = 0.4

var _active: bool = false
var _ball_in_range: RigidBody2D = null
@onready var _sprite: Polygon2D = $Sprite

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_visual()

func _physics_process(_delta: float) -> void:
	if _active and _ball_in_range:
		var pull_dir := (global_position - _ball_in_range.global_position).normalized()
		_ball_in_range.apply_central_force(pull_dir * pull_strength)

func activate() -> void:
	_active = true
	_update_visual()
	activated.emit()
	await get_tree().create_timer(active_duration_seconds).timeout
	_active = false
	_update_visual()
	deactivated.emit()

func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		_ball_in_range = body

func _on_body_exited(body: Node2D) -> void:
	if body == _ball_in_range:
		_ball_in_range = null

func _update_visual() -> void:
	_sprite.color = Color(1, 0.85, 0.2, 1) if _active else Color(0.4, 0.4, 0.45, 1)

# Built with assistance from Claude Code by Anthropic.
