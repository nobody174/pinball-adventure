extends GutTest

const PinballTableScene := preload("res://core/table_base/pinball_table.tscn")

class FakeHitNode:
	extends Node
	signal hit(target_id: String)

func _make_table() -> PinballTable:
	var table: PinballTable = PinballTableScene.instantiate()
	add_child_autofree(table)
	return table

func test_wire_hit_group_adds_score_on_hit() -> void:
	var table := _make_table()
	GameState.reset_score()
	var node := FakeHitNode.new()
	add_child_autofree(node)

	table.wire_hit_group([node], 250)
	node.hit.emit("some_id")

	assert_eq(GameState.score, 250)

func test_wire_hit_group_registers_target_hit_with_objectives() -> void:
	var table := _make_table()
	table.objectives.load_from_config([
		{"id": "test_objective", "type": "hit_targets", "target_ids": ["a"]},
	])
	var node := FakeHitNode.new()
	node.name = "a_node"
	add_child_autofree(node)

	watch_signals(table)
	table.wire_hit_group([node], 0)
	node.hit.emit("a")

	assert_signal_emitted(table, "objective_completed")

func test_wire_hit_group_calls_optional_on_hit_callback() -> void:
	var table := _make_table()
	var node := FakeHitNode.new()
	add_child_autofree(node)

	var received: Array = [""] ## Array, not a plain String -- GDScript lambdas capture outer locals by value, so mutating a plain var wouldn't be visible here.
	table.wire_hit_group([node], 0, func(id: String) -> void: received[0] = id)
	node.hit.emit("logged_id")

	assert_eq(received[0], "logged_id")

func test_wire_hit_group_works_without_a_callback() -> void:
	var table := _make_table()
	var node := FakeHitNode.new()
	add_child_autofree(node)

	table.wire_hit_group([node], 10) ## No callback passed -- should not error.
	node.hit.emit("id")

	pass_test("no callback should not raise an error")

func test_register_ball_forwards_drained_as_ball_lost() -> void:
	## The ball_lost signal exists specifically so a table can react to a
	## ball leaving play, but it's the table that owns it while individual
	## PinballBall instances own drain detection (see ball.gd) -- register_ball
	## is the seam connecting the two, needed for both the main ball and any
	## multiball-spawned ones.
	var table := _make_table()
	var ball := RigidBody2D.new()
	ball.set_script(load("res://core/physics/ball.gd"))
	add_child_autofree(ball)
	watch_signals(table)

	table.register_ball(ball)
	ball.drained.emit()

	assert_signal_emitted(table, "ball_lost")

func test_start_multiball_releases_first_ball_immediately() -> void:
	var table := _make_table()
	var balls_before := table.get_children().filter(func(c): return c is PinballBall).size()

	table.start_multiball(3, Vector2(100, 100), Vector2(0, -800))

	var balls_after := table.get_children().filter(func(c): return c is PinballBall).size()
	assert_eq(balls_after, balls_before + 1, "the first queued ball should spawn synchronously, not wait for the release timer")

func test_start_multiball_emits_ball_released_with_remaining_count() -> void:
	var table := _make_table()
	watch_signals(table)

	table.start_multiball(3, Vector2(100, 100), Vector2(0, -800))

	## 3 requested, 1 just released -- 2 should remain queued.
	assert_signal_emitted_with_parameters(table, "multiball_ball_released", [2])

func test_start_multiball_releases_remaining_balls_over_time() -> void:
	var table := _make_table()
	table.start_multiball(2, Vector2(100, 100), Vector2(0, -800), 0.05)
	var balls_immediately := table.get_children().filter(func(c): return c is PinballBall).size()

	await wait_seconds(0.15)

	var balls_after_wait := table.get_children().filter(func(c): return c is PinballBall).size()
	assert_eq(balls_immediately, 1, "only the first ball should exist before the release interval elapses")
	assert_eq(balls_after_wait, 2, "the second queued ball should have been released after the interval")

func test_start_multiball_emits_multiball_ready_once_queue_is_empty() -> void:
	var table := _make_table()
	watch_signals(table)

	table.start_multiball(1, Vector2(100, 100), Vector2(0, -800)) ## Only 1 ball -- queue empties on the very first (synchronous) release.

	assert_signal_emitted(table, "multiball_ready")
