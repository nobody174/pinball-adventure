extends GutTest

const BumperScript := preload("res://core/physics/bumper.gd")

func _make_bumper() -> Area2D:
	var bumper := Area2D.new()
	bumper.set_script(BumperScript)
	add_child_autofree(bumper)
	return bumper

func test_kicks_ball_on_contact() -> void:
	var bumper := _make_bumper()
	watch_signals(bumper)

	bumper._on_body_entered(autofree(RigidBody2D.new()))

	assert_signal_emitted(bumper, "kicked")

func test_does_not_kick_again_during_cooldown() -> void:
	## Regression test: bumper previously had no cooldown at all -- a ball
	## rattling inside the circular Area2D could re-trigger body_entered
	## many times per second, an uncapped scoring exploit (found via live
	## MCP playtesting: score jumped 15850 -> 60175 in ~2 seconds).
	var bumper := _make_bumper()
	bumper.kick_cooldown_seconds = 1.0
	var ball: RigidBody2D = autofree(RigidBody2D.new())

	bumper._on_body_entered(ball)
	watch_signals(bumper)
	bumper._on_body_entered(ball) ## Still within cooldown -- should be ignored.

	assert_signal_not_emitted(bumper, "kicked")

func test_hit_signal_only_emitted_when_target_id_set() -> void:
	var bumper := _make_bumper()
	bumper.target_id = "test_target"
	watch_signals(bumper)

	bumper._on_body_entered(autofree(RigidBody2D.new()))

	assert_signal_emitted_with_parameters(bumper, "hit", ["test_target"])

func test_non_rigidbody_does_not_kick() -> void:
	var bumper := _make_bumper()
	watch_signals(bumper)

	bumper._on_body_entered(autofree(Node2D.new()))

	assert_signal_not_emitted(bumper, "kicked")
