extends GutTest

const CaptiveBallScript := preload("res://core/physics/captive_ball.gd")

func _make_captive_ball() -> RigidBody2D:
	var ball := RigidBody2D.new()
	ball.set_script(CaptiveBallScript)
	ball.target_id = "captive_a"
	add_child_autofree(ball)
	return ball

func test_struck_emits_target_id_on_contact_from_another_body() -> void:
	var captive := _make_captive_ball()
	var real_ball := RigidBody2D.new()
	add_child_autofree(real_ball)
	watch_signals(captive)

	captive._on_body_entered(real_ball)

	assert_signal_emitted_with_parameters(captive, "struck", ["captive_a"])

func test_does_not_emit_struck_from_non_rigidbody_contact() -> void:
	var captive := _make_captive_ball()
	watch_signals(captive)

	captive._on_body_entered(autofree(Node2D.new()))

	assert_signal_not_emitted(captive, "struck")

func test_does_not_emit_struck_from_self_contact() -> void:
	var captive := _make_captive_ball()
	watch_signals(captive)

	captive._on_body_entered(captive)

	assert_signal_not_emitted(captive, "struck")
