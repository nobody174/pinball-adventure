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
var _pending_teleport: bool = false
var _pending_teleport_position: Vector2
var _pending_teleport_velocity: Vector2
var _ccd_reenable_countdown: int = -1

func _ready() -> void:
	var mat := PhysicsMaterial.new()
	mat.bounce = restitution
	mat.friction = friction
	physics_material_override = mat
	contact_monitor = true
	max_contacts_reported = 4
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
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

	## CCD_MODE_CAST_SHAPE sweeps from the body's position at the start of the
	## step to its new one -- after a direct transform write (teleport or
	## respawn), that sweep can still be computed from wherever the ball was
	## *before* the jump, producing a bogus collision against whatever
	## geometry happens to lie along that (physically meaningless) line.
	## Keep CCD off for a couple of frames after any teleport so the solver
	## never has stale start/end points to sweep between.
	if _ccd_reenable_countdown > 0:
		_ccd_reenable_countdown -= 1
		if _ccd_reenable_countdown == 0:
			continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE

## Debug-only: instantly place the ball at an arbitrary position, e.g. to
## deterministically test a specific shot (saucer, loop mouth) without
## relying on lucky flipper-cascade RNG. Not exposed to normal play — see
## the OS.is_debug_build() gate on the caller in the_glitch.gd.
func request_teleport(target_position: Vector2, target_velocity: Vector2 = Vector2.ZERO) -> void:
	_pending_teleport_position = target_position
	_pending_teleport_velocity = target_velocity
	_pending_teleport = true

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
		continuous_cd = RigidBody2D.CCD_MODE_DISABLED
		_ccd_reenable_countdown = 2
	if _pending_teleport:
		state.transform = Transform2D(0.0, _pending_teleport_position)
		state.linear_velocity = _pending_teleport_velocity
		state.angular_velocity = 0.0
		state.sleeping = false
		_pending_teleport = false
		continuous_cd = RigidBody2D.CCD_MODE_DISABLED
		_ccd_reenable_countdown = 2
