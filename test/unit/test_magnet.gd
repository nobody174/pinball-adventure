extends GutTest

const MagnetScript := preload("res://core/physics/magnet.gd")

func _make_magnet() -> Area2D:
	var magnet := Area2D.new()
	magnet.set_script(MagnetScript)
	magnet.pull_strength = 500.0
	magnet.active_duration_seconds = 0.05
	var sprite := Polygon2D.new()
	sprite.name = "Sprite"
	magnet.add_child(sprite)
	add_child_autofree(magnet)
	return magnet

func _make_ball(pos: Vector2) -> RigidBody2D:
	var ball := RigidBody2D.new()
	ball.gravity_scale = 0.0
	ball.global_position = pos
	add_child_autofree(ball)
	return ball

func test_pulls_ball_toward_center_while_active() -> void:
	var magnet := _make_magnet()
	magnet.global_position = Vector2(0, 0)
	var ball := _make_ball(Vector2(100, 0))
	magnet._on_body_entered(ball)

	magnet.activate()
	await wait_physics_frames(3)

	assert_lt(ball.linear_velocity.x, 0.0, "ball should be pulled toward the magnet (negative x, toward origin)")

func test_does_not_pull_ball_when_inactive() -> void:
	var magnet := _make_magnet()
	magnet.global_position = Vector2(0, 0)
	var ball := _make_ball(Vector2(100, 0))
	magnet._on_body_entered(ball)

	await wait_physics_frames(3)

	assert_eq(ball.linear_velocity, Vector2.ZERO, "no pull should be applied while inactive")

func test_stops_pulling_after_ball_exits_range() -> void:
	var magnet := _make_magnet()
	magnet.global_position = Vector2(0, 0)
	var ball := _make_ball(Vector2(100, 0))
	magnet._on_body_entered(ball)
	magnet._on_body_exited(ball)

	magnet.activate()
	await wait_physics_frames(3)

	assert_eq(ball.linear_velocity, Vector2.ZERO, "ball that left the area should no longer be pulled")

func test_activate_emits_activated_then_deactivated() -> void:
	var magnet := _make_magnet()
	watch_signals(magnet)

	magnet.activate()
	assert_signal_emitted(magnet, "activated")

	await wait_seconds(0.1)

	assert_signal_emitted(magnet, "deactivated")
