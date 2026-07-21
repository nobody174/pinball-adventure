extends GutTest

const RolloverScript := preload("res://core/physics/rollover.gd")
const BallScript := preload("res://core/physics/ball.gd")

func _make_rollover() -> Area2D:
	var rollover := Area2D.new()
	rollover.set_script(RolloverScript)
	rollover.target_id = "lane_a"
	add_child_autofree(rollover)
	return rollover

func _make_ball(velocity: Vector2) -> RigidBody2D:
	var ball := RigidBody2D.new()
	ball.set_script(BallScript)
	ball.linear_velocity = velocity
	add_child_autofree(ball)
	return ball

func test_rolls_over_when_moving_in_scoring_direction() -> void:
	var rollover := _make_rollover()
	watch_signals(rollover)

	rollover._on_body_entered(_make_ball(Vector2(0, -400))) ## moving "up" through the lane

	assert_signal_emitted_with_parameters(rollover, "rolled_over", ["lane_a"])

func test_does_not_roll_over_when_moving_the_wrong_way() -> void:
	var rollover := _make_rollover()
	watch_signals(rollover)

	rollover._on_body_entered(_make_ball(Vector2(0, 400))) ## moving "down" -- the ball rattled back out

	assert_signal_not_emitted(rollover, "rolled_over")

func test_direction_is_relative_to_the_rollover_own_rotation() -> void:
	## The scoring direction always means "the same local direction through
	## the lane," regardless of how the node is rotated on the table -- so a
	## rollover placed sideways doesn't need special-cased velocity math.
	var rollover := _make_rollover()
	rollover.rotation = deg_to_rad(90)
	watch_signals(rollover)

	## In world space this is "moving right," but rotated into the
	## rollover's own local frame (rotated 90 degrees) it matches the same
	## scoring direction as the unrotated up-motion case above.
	rollover._on_body_entered(_make_ball(Vector2(400, 0)))

	assert_signal_emitted_with_parameters(rollover, "rolled_over", ["lane_a"])

func test_non_ball_does_not_roll_over() -> void:
	var rollover := _make_rollover()
	watch_signals(rollover)

	rollover._on_body_entered(autofree(RigidBody2D.new()))

	assert_signal_not_emitted(rollover, "rolled_over")

func test_non_rigidbody_does_not_roll_over() -> void:
	var rollover := _make_rollover()
	watch_signals(rollover)

	rollover._on_body_entered(autofree(Node2D.new()))

	assert_signal_not_emitted(rollover, "rolled_over")
