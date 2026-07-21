extends GutTest

const RotatingToyScene := preload("res://core/physics/rotating_toy.gd")
const BallScript := preload("res://core/physics/ball.gd")

func _make_toy() -> Area2D:
	var toy := Area2D.new()
	toy.set_script(RotatingToyScene)
	var sprite := Polygon2D.new()
	sprite.name = "Sprite"
	toy.add_child(sprite)
	add_child_autofree(toy)
	return toy

func _make_ball() -> RigidBody2D:
	var ball := RigidBody2D.new()
	ball.set_script(BallScript)
	add_child_autofree(ball)
	return ball

func test_starts_uncharged_with_uncharged_color() -> void:
	var toy := _make_toy()
	assert_false(toy.charged)
	assert_eq(toy.get_node("Sprite").color, toy.uncharged_color)

func test_setting_charged_updates_sprite_color() -> void:
	var toy := _make_toy()
	toy.charged = true
	assert_eq(toy.get_node("Sprite").color, toy.charged_color)

func test_body_entered_emits_hit_while_charged_when_charged() -> void:
	var toy := _make_toy()
	toy.charged = true
	watch_signals(toy)
	toy._on_body_entered(_make_ball())
	assert_signal_emitted(toy, "hit_while_charged")
	assert_signal_not_emitted(toy, "hit_while_uncharged")

func test_body_entered_emits_hit_while_uncharged_when_not_charged() -> void:
	var toy := _make_toy()
	watch_signals(toy)
	toy._on_body_entered(_make_ball())
	assert_signal_emitted(toy, "hit_while_uncharged")
	assert_signal_not_emitted(toy, "hit_while_charged")

func test_non_ball_does_not_trigger_hit() -> void:
	## Regression test: a flipper is a RigidBody2D too (kinematically driven)
	## and could be knocked into the toy's Area2D by the ball -- must not be
	## treated as a real hit. See saucer.gd's identical, more severe version
	## of this bug (fixed this session).
	var toy := _make_toy()
	watch_signals(toy)
	toy._on_body_entered(autofree(RigidBody2D.new()))
	assert_signal_not_emitted(toy, "hit_while_charged")
	assert_signal_not_emitted(toy, "hit_while_uncharged")

func test_non_rigidbody_does_not_trigger_hit() -> void:
	var toy := _make_toy()
	watch_signals(toy)
	toy._on_body_entered(autofree(Node2D.new()))
	assert_signal_not_emitted(toy, "hit_while_charged")
	assert_signal_not_emitted(toy, "hit_while_uncharged")

func test_raise_gate_emits_gate_raised() -> void:
	var toy := _make_toy()
	watch_signals(toy)

	toy.raise_gate(0)

	assert_signal_emitted_with_parameters(toy, "gate_raised", [0])
	assert_false(toy.are_all_gates_raised(), "only 1 of 3 gates raised")

func test_raising_same_gate_twice_does_not_re_emit() -> void:
	var toy := _make_toy()
	toy.raise_gate(1)
	watch_signals(toy)

	toy.raise_gate(1)

	assert_signal_not_emitted(toy, "gate_raised", "already-raised gate should be a no-op")

func test_all_gates_raised_fires_once_the_third_gate_is_raised() -> void:
	var toy := _make_toy()
	watch_signals(toy)

	toy.raise_gate(0)
	toy.raise_gate(1)
	assert_signal_not_emitted(toy, "all_gates_raised", "only 2 of 3 gates raised so far")
	toy.raise_gate(2)

	assert_signal_emitted(toy, "all_gates_raised")
	assert_true(toy.are_all_gates_raised())

func test_reset_gates_clears_all_progress() -> void:
	var toy := _make_toy()
	toy.raise_gate(0)
	toy.raise_gate(1)
	toy.raise_gate(2)

	toy.reset_gates()

	assert_false(toy.are_all_gates_raised())

func test_overload_speed_only_applies_once_all_gates_raised() -> void:
	var toy := _make_toy()
	toy.rotation_speed = 1.0
	toy.overload_rotation_speed = 6.0
	var start_rotation := toy.rotation

	toy._process(1.0)
	var rotation_before_gates: float = toy.rotation - start_rotation

	toy.raise_gate(0)
	toy.raise_gate(1)
	toy.raise_gate(2)
	var mid_rotation := toy.rotation
	toy._process(1.0)
	var rotation_after_gates: float = toy.rotation - mid_rotation

	assert_almost_eq(rotation_before_gates, 1.0, 0.001, "idle speed should apply before all gates are raised")
	assert_almost_eq(rotation_after_gates, 6.0, 0.001, "overload speed should apply once all gates are raised")
