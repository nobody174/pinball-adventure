extends GutTest

const BallScript := preload("res://core/physics/ball.gd")

func _make_ball() -> RigidBody2D:
	var ball := RigidBody2D.new()
	ball.set_script(BallScript)
	var sprite := Polygon2D.new()
	sprite.name = "Sprite"
	ball.add_child(sprite)
	add_child_autofree(ball)
	return ball

func test_teleport_moves_ball_to_target_position() -> void:
	var ball := _make_ball()
	ball.global_position = Vector2(50, 50)

	ball.request_teleport(Vector2(300, -400))
	await wait_physics_frames(2) ## Teleport applies in _integrate_forces, not instantly.

	assert_almost_eq(ball.global_position.x, 300.0, 1.0)
	assert_almost_eq(ball.global_position.y, -400.0, 1.0)

func test_teleport_applies_given_velocity() -> void:
	var ball := _make_ball()
	ball.gravity_scale = 0.0 ## Isolate the teleport velocity from gravity's pull during the waited frames.

	ball.request_teleport(Vector2(100, 100), Vector2(0, -600))
	await wait_physics_frames(2)

	assert_almost_eq(ball.linear_velocity.y, -600.0, 2.0)

func test_teleport_does_not_leave_ball_stuck_afterward() -> void:
	## Regression guard for the exact bug this pattern was built to avoid:
	## writing position directly (outside _integrate_forces) previously left
	## the ball permanently frozen with gravity no longer applying. Confirm
	## a teleported ball still falls under gravity afterward.
	var ball := _make_ball()
	ball.global_position = Vector2(200, -500)

	ball.request_teleport(Vector2(200, -500))
	await wait_physics_frames(2)
	var y_after_teleport := ball.global_position.y
	await wait_physics_frames(10)

	assert_gt(ball.global_position.y, y_after_teleport, "ball should keep falling under gravity after a teleport, not freeze in place")

func test_teleport_disables_ccd_then_reenables_it() -> void:
	## Regression test: caught via live MCP playtesting -- a ball teleported
	## into an empty corridor was getting ejected sideways into unrelated
	## geometry it was nowhere near. Root cause: CCD_MODE_CAST_SHAPE sweeps
	## from the body's pre-teleport position to its new one, so a direct
	## transform write can still trigger a bogus collision against whatever
	## lies along that (physically meaningless) line. CCD must be off for a
	## couple of frames after any teleport, then safely back on.
	var ball := _make_ball()
	assert_eq(ball.continuous_cd, RigidBody2D.CCD_MODE_CAST_SHAPE, "sanity check: CCD should be on by default")

	ball.request_teleport(Vector2(300, -400))
	await wait_physics_frames(1)

	assert_eq(ball.continuous_cd, RigidBody2D.CCD_MODE_DISABLED, "CCD should be off immediately after a teleport")

	await wait_physics_frames(2)

	assert_eq(ball.continuous_cd, RigidBody2D.CCD_MODE_CAST_SHAPE, "CCD should be back on a couple of frames later")
