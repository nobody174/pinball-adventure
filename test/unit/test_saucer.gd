extends GutTest

const SaucerScript := preload("res://core/physics/saucer.gd")

func _make_saucer() -> Area2D:
	var saucer := Area2D.new()
	saucer.set_script(SaucerScript)
	saucer.target_id = "saucer_a"
	saucer.hold_duration_seconds = 0.05
	saucer.eject_direction = Vector2.UP
	saucer.eject_strength = 200.0
	var sprite := Polygon2D.new()
	sprite.name = "Sprite"
	saucer.add_child(sprite)
	saucer.global_position = Vector2(100, 100)
	add_child_autofree(saucer)
	return saucer

func _make_ball() -> RigidBody2D:
	var ball := RigidBody2D.new()
	ball.gravity_scale = 0.0 ## Isolate the eject impulse from gravity during the waited frames.
	add_child_autofree(ball)
	return ball

func test_captures_ball_on_contact() -> void:
	var saucer := _make_saucer()
	var ball := _make_ball()
	ball.global_position = Vector2(500, 500)
	watch_signals(saucer)

	saucer._on_body_entered(ball)

	assert_signal_emitted_with_parameters(saucer, "captured", ["saucer_a"])
	assert_true(ball.freeze, "ball should be frozen while held")
	assert_eq(ball.global_position, saucer.global_position, "ball should snap into the saucer")

func test_ejects_ball_after_hold_duration() -> void:
	var saucer := _make_saucer()
	var ball := _make_ball()
	watch_signals(saucer)

	saucer._on_body_entered(ball)
	await wait_seconds(0.1) ## Longer than hold_duration_seconds (0.05).
	await wait_physics_frames(3) ## apply_central_impulse only takes effect on a later physics step.

	assert_signal_emitted_with_parameters(saucer, "ejected", ["saucer_a"])
	assert_false(ball.freeze, "ball should be released after the hold")
	assert_almost_eq(ball.linear_velocity.y, -200.0, 5.0, "eject impulse should push the ball up at eject_strength")

func test_non_rigidbody_is_not_captured() -> void:
	var saucer := _make_saucer()
	watch_signals(saucer)

	saucer._on_body_entered(autofree(Node2D.new()))

	assert_signal_not_emitted(saucer, "captured")

func test_second_contact_during_hold_is_ignored() -> void:
	var saucer := _make_saucer()
	var ball := _make_ball()
	saucer._on_body_entered(ball)
	watch_signals(saucer)

	saucer._on_body_entered(_make_ball()) ## Still holding the first ball -- should be ignored.

	assert_signal_not_emitted(saucer, "captured")
