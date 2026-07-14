extends Area2D

## Placeholder pinball bumper. The sibling StaticBody2D handles solid
## collision/bounce; this Area2D adds the extra outward "kick" impulse a real
## bumper gives beyond passive restitution.

signal kicked
signal hit(target_id: String) ## Only emitted if target_id is set — lets a bumper feed the objective system.

@export var kick_strength: float = 600.0
@export var target_id: String = ""

func _on_body_entered(body: Node2D) -> void:
	if not body is RigidBody2D:
		return
	var direction := (body.global_position - global_position).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.UP
	body.apply_central_impulse(direction * kick_strength)
	kicked.emit()
	if target_id != "":
		hit.emit(target_id)
