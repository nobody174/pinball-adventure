extends GutTest

const SpinnerScript := preload("res://core/physics/spinner.gd")

func _make_spinner() -> Area2D:
	var spinner := Area2D.new()
	spinner.set_script(SpinnerScript)
	spinner.target_id = "spin_a"
	var sprite := Polygon2D.new()
	sprite.name = "Sprite"
	spinner.add_child(sprite)
	add_child_autofree(spinner)
	return spinner

func test_spins_and_emits_id_on_contact() -> void:
	var spinner := _make_spinner()
	watch_signals(spinner)

	spinner._on_body_entered(autofree(RigidBody2D.new()))

	assert_signal_emitted_with_parameters(spinner, "spun", ["spin_a"])

func test_does_not_spin_again_during_cooldown() -> void:
	## Regression test: caught in code review before it ever shipped as a
	## live exploit (unlike bumper.gd's identical bug, which was only found
	## via live MCP playtesting) -- spun.emit() had no cooldown at all,
	## only the visual tween was guarded by _spinning. A ball resting on
	## the thin Area2D's edge could re-trigger body_entered repeatedly.
	var spinner := _make_spinner()
	spinner.spin_cooldown_seconds = 1.0
	var ball: RigidBody2D = autofree(RigidBody2D.new())

	spinner._on_body_entered(ball)
	watch_signals(spinner)
	spinner._on_body_entered(ball) ## Still within cooldown -- should be ignored.

	assert_signal_not_emitted(spinner, "spun")

func test_non_rigidbody_does_not_spin() -> void:
	var spinner := _make_spinner()
	watch_signals(spinner)

	spinner._on_body_entered(autofree(Node2D.new()))

	assert_signal_not_emitted(spinner, "spun")

func test_repeated_contact_during_spin_does_not_restart_tween() -> void:
	var spinner := _make_spinner()
	var ball: RigidBody2D = autofree(RigidBody2D.new())

	spinner._on_body_entered(ball)
	var spinning_after_first_hit: bool = spinner._spinning
	spinner._on_body_entered(ball)

	assert_true(spinning_after_first_hit, "spinner should be mid-spin immediately after a hit")
	assert_true(spinner._spinning, "second hit during the same spin should not break the in-progress state")
