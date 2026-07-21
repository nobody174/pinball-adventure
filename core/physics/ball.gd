#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends RigidBody2D
class_name PinballBall

## Placeholder pinball. Tunable in the inspector for §10a feel-testing.

@export var restitution: float = 0.6
@export var friction: float = 0.1
@export var nudge_impulse: float = 400.0
@export var nudge_cooldown_seconds: float = 0.4
@export var launch_impulse_min: float = 250.0
@export var launch_impulse_max: float = 2600.0
@export var launch_charge_duration_seconds: float = 0.8
@export var max_velocity: float = 4500.0 ## Safety clamp, not a gameplay tuning knob -- see _integrate_forces.

signal launch_charge_changed(charge_ratio: float)
signal drained ## Emitted the moment this ball leaves play (see the y>900/off-table check below).

var _spawn_position: Vector2
var _nudge_cooldown_remaining: float = 0.0
var _launched: bool = false
var _launch_charge: float = 0.0
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
	add_to_group("balls") ## Group tag alongside class_name PinballBall -- lets
	## table/objective code use the common Godot is_in_group("balls") /
	## get_tree().get_nodes_in_group("balls") idiom without needing to know
	## about (or import) this specific script's type.

func _physics_process(delta: float) -> void:
	## Real charge-and-release plunger: hold launch_ball to pull back (charge
	## ramps 0->1 over launch_charge_duration_seconds), release to fire an
	## impulse scaled between launch_impulse_min/max by how long it was held
	## -- replaces the old instant-fire placeholder now that there's an
	## actual shooter lane + visual plunger rod for this to drive.
	if not _launched:
		if Input.is_action_pressed("launch_ball"):
			_launch_charge = clampf(_launch_charge + delta / launch_charge_duration_seconds, 0.0, 1.0)
			launch_charge_changed.emit(_launch_charge)
		if Input.is_action_just_released("launch_ball") and _launch_charge > 0.0:
			var impulse := lerpf(launch_impulse_min, launch_impulse_max, _launch_charge)
			apply_central_impulse(Vector2(0, -1.0) * impulse)
			_launched = true
			_launch_charge = 0.0
			launch_charge_changed.emit(0.0)

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
		drained.emit()

	## A weak shot can fall back and settle in the shooter lane itself
	## (on the lane floor, around y=700-780) without ever crossing the drain
	## threshold above -- that used to leave _launched permanently true,
	## silently locking out the plunger forever (the charge branch above only
	## runs `if not _launched`). Detect "at rest back in the lane" directly
	## rather than only reacting to leaving the table entirely.
	if _launched and position.y > 690 and position.y < 800 and absf(position.x - 423) < 30 and linear_velocity.length() < 20.0:
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
	## Safety net, not a fix for a known root cause: rare, hard-to-reproduce
	## collision interactions (e.g. a fast ball catching a seam or corner at
	## an unlucky angle) can in principle hand the solver a velocity far
	## beyond anything a real shot should produce. Other Godot pinball
	## projects hit the same class of issue and ship the same mitigation
	## (a sane clamp) rather than claiming to have found every root cause —
	## this doesn't replace fixing an actual bug if one is found, it just
	## stops a rare one from launching the ball off the table unrecoverably.
	var velocity := state.get_linear_velocity()
	if velocity.length() > max_velocity:
		state.set_linear_velocity(velocity.limit_length(max_velocity))

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

# Built with assistance from Claude Code by Anthropic.
