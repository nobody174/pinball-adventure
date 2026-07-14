extends GutTest

const SlingshotScript := preload("res://core/physics/slingshot.gd")

func _make_slingshot() -> Area2D:
	var sling := Area2D.new()
	sling.set_script(SlingshotScript)
	sling.kick_direction = Vector2.UP
	sling.kick_strength = 100.0
	var sprite := Polygon2D.new()
	sprite.name = "Sprite"
	sling.add_child(sprite)
	add_child_autofree(sling)
	return sling

func test_kicks_ball_on_contact() -> void:
	var sling := _make_slingshot()
	var ball := RigidBody2D.new()
	ball.gravity_scale = 0.0 ## Isolate the impulse itself from gravity's pull during the waited frames.
	add_child_autofree(ball) ## Must be in the tree for the physics step to apply the impulse.
	watch_signals(sling)

	sling._on_body_entered(ball)
	await wait_physics_frames(3) ## apply_central_impulse only takes effect on a later physics step.

	assert_signal_emitted(sling, "kicked")
	assert_almost_eq(ball.linear_velocity.y, -100.0, 2.0, "impulse should push the ball up at kick_strength (small tolerance for linear damping over the waited frames)")
	assert_almost_eq(ball.linear_velocity.x, 0.0, 0.01)

func test_does_not_kick_again_during_cooldown() -> void:
	var sling := _make_slingshot()
	sling.kick_cooldown_seconds = 1.0
	var ball: RigidBody2D = autofree(RigidBody2D.new())

	sling._on_body_entered(ball)
	watch_signals(sling)
	sling._on_body_entered(ball) ## Still within cooldown -- should be ignored.

	assert_signal_not_emitted(sling, "kicked")

func test_non_rigidbody_does_not_kick() -> void:
	var sling := _make_slingshot()
	watch_signals(sling)

	sling._on_body_entered(autofree(Node2D.new()))

	assert_signal_not_emitted(sling, "kicked")
