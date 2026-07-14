extends Area2D

## Placeholder pinball bumper. The sibling StaticBody2D handles solid
## collision/bounce; this Area2D adds the extra outward "kick" impulse a real
## bumper gives beyond passive restitution.

signal kicked
signal hit(target_id: String) ## Only emitted if target_id is set — lets a bumper feed the objective system.

@export var kick_strength: float = 600.0
@export var target_id: String = ""
@export var kick_cooldown_seconds: float = 0.15 ## Without this, a ball rattling inside the circular Area2D re-triggers body_entered many times per second — an uncapped scoring exploit.

var _cooldown_remaining: float = 0.0

func _physics_process(delta: float) -> void:
	_cooldown_remaining = maxf(0.0, _cooldown_remaining - delta)

func _on_body_entered(body: Node2D) -> void:
	if not body is RigidBody2D or _cooldown_remaining > 0.0:
		return
	var direction := (body.global_position - global_position).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.UP
	body.apply_central_impulse(direction * kick_strength)
	kicked.emit()
	if target_id != "":
		hit.emit(target_id)
	_cooldown_remaining = kick_cooldown_seconds
