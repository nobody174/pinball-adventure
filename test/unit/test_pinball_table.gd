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
