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
@onready var _sprite: Polygon2D = $Sprite

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body is RigidBody2D or _holding:
		return
	_holding = true
	captured.emit(target_id)
	body.freeze = true
	body.linear_velocity = Vector2.ZERO
	body.global_position = global_position
	await get_tree().create_timer(hold_duration_seconds).timeout
	body.freeze = false
	body.apply_central_impulse(eject_direction.normalized() * eject_strength)
	ejected.emit(target_id)
	_holding = false
