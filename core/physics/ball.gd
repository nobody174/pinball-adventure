extends RigidBody2D

## Placeholder pinball. Tunable in the inspector for §10a feel-testing.

@export var restitution: float = 0.6
@export var friction: float = 0.1

func _ready() -> void:
	var mat := PhysicsMaterial.new()
	mat.bounce = restitution
	mat.friction = friction
	physics_material_override = mat
	contact_monitor = true
	max_contacts_reported = 4
