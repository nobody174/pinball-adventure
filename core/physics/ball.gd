extends RigidBody2D

## Placeholder pinball. Tunable in the inspector for §10a feel-testing.

@export var restitution: float = 0.6
@export var friction: float = 0.1
@export var nudge_impulse: float = 400.0
@export var nudge_cooldown_seconds: float = 0.4
@export var launch_impulse: float = 500.0

var _spawn_position: Vector2
var _nudge_cooldown_remaining: float = 0.0
var _launched: bool = false
var _pending_respawn: bool = false

func _ready() -> void:
	var mat := PhysicsMaterial.new()
	mat.bounce = restitution
	mat.friction = friction
	physics_material_override = mat
	contact_monitor = true
	max_contacts_reported = 4
	_spawn_position = position

func _physics_process(delta: float) -> void:
	## Placeholder launch: no plunger/lane yet (GDD hasn't reached that), so
	## this is just a direct impulse stand-in — real plunger feel is later work.
	if not _launched and Input.is_action_just_pressed("launch_ball"):
		apply_central_impulse(Vector2(0, -1.0) * launch_impulse)
		_launched = true

	_nudge_cooldown_remaining = maxf(0.0, _nudge_cooldown_remaining - delta)
	if Input.is_action_just_pressed("nudge") and _nudge_cooldown_remaining <= 0.0:
		## Placeholder nudge: small sideways+up impulse, cooldown stands in for
		## tilt until a real tilt-lockout system exists (see physics_notes.md).
		var direction := 1.0 if randf() < 0.5 else -1.0
		apply_central_impulse(Vector2(direction, -0.6) * nudge_impulse)
		_nudge_cooldown_remaining = nudge_cooldown_seconds

	## Placeholder drain/recovery: §10a has no plunger or drain-out UI yet, so a
	## ball that leaves the play area (drains, or gets knocked out) just
	## respawns rather than being lost for the rest of the playtest session.
	if position.y > 900 or absf(position.x - 210) > 600:
		_pending_respawn = true
		_launched = false

## Writing position/linear_velocity directly on a RigidBody2D outside this
## callback fights the physics server's own transform sync and can leave the
## body stuck with gravity no longer applying — teleports must go through here.
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _pending_respawn:
		state.transform = Transform2D(0.0, _spawn_position)
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		state.sleeping = false
		_pending_respawn = false
