extends Node2D

## Stand-in for "multiple moving objects on-table simultaneously" — a
## decorative orbiting/spinning element, not gameplay-relevant. §10b only
## cares about the render/update cost of having several of these active.

@export var orbit_center: Vector2 = Vector2(210, 350)
@export var orbit_radius: float = 180.0
@export var orbit_speed: float = 1.0
@export var phase_offset: float = 0.0

func _process(delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0 * orbit_speed + phase_offset
	position = orbit_center + Vector2(cos(t), sin(t) * 0.4) * orbit_radius
	rotation += delta * 3.0
