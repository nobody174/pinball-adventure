extends GutTest

const HitTargets := preload("res://core/objectives/objective_types/hit_targets.gd")

func test_completes_when_all_targets_hit_any_order() -> void:
	var objective := HitTargets.new()
	objective.target_ids = ["a", "b", "c"]
	objective.require_order = false
	add_child_autofree(objective)

	watch_signals(objective)
	objective.notify_target_hit("c")
	objective.notify_target_hit("a")
	objective.notify_target_hit("b")

	assert_signal_emitted(objective, "completed")
	assert_true(objective.is_complete())

func test_ordered_objective_requires_correct_sequence() -> void:
	var objective := HitTargets.new()
	objective.target_ids = ["a", "b", "c"]
	objective.require_order = true
	add_child_autofree(objective)

	watch_signals(objective)
	objective.notify_target_hit("a")
	objective.notify_target_hit("b")

	assert_signal_not_emitted(objective, "completed")
	assert_false(objective.is_complete())

func test_ordered_objective_resets_progress_on_wrong_order_hit() -> void:
	var objective := HitTargets.new()
	objective.target_ids = ["a", "b", "c"]
	objective.require_order = true
	add_child_autofree(objective)

	objective.notify_target_hit("a")
	objective.notify_target_hit("c") ## Wrong order — should reset progress, not just ignore.
	objective.notify_target_hit("b")
	objective.notify_target_hit("c")

	assert_false(objective.is_complete(), "hitting b after the reset shouldn't count toward completion")

func test_ordered_objective_completes_on_correct_sequence() -> void:
	var objective := HitTargets.new()
	objective.target_ids = ["a", "b", "c"]
	objective.require_order = true
	add_child_autofree(objective)

	watch_signals(objective)
	objective.notify_target_hit("a")
	objective.notify_target_hit("b")
	objective.notify_target_hit("c")

	assert_signal_emitted(objective, "completed")

func test_unknown_target_id_is_ignored() -> void:
	var objective := HitTargets.new()
	objective.target_ids = ["a", "b"]
	add_child_autofree(objective)

	watch_signals(objective)
	objective.notify_target_hit("not_a_real_target")

	assert_signal_not_emitted(objective, "completed")

func test_wrong_order_hit_emits_sequence_reset_when_progress_existed() -> void:
	var objective := HitTargets.new()
	objective.target_ids = ["a", "b", "c"]
	objective.require_order = true
	add_child_autofree(objective)

	watch_signals(objective)
	objective.notify_target_hit("a")
	objective.notify_target_hit("c") ## Wrong order after real progress — should be reported.

	assert_signal_emitted(objective, "sequence_reset")

func test_wrong_first_hit_does_not_emit_sequence_reset() -> void:
	var objective := HitTargets.new()
	objective.target_ids = ["a", "b", "c"]
	objective.require_order = true
	add_child_autofree(objective)

	watch_signals(objective)
	objective.notify_target_hit("b") ## Wrong from the start — nothing to "reset" yet.

	assert_signal_not_emitted(objective, "sequence_reset")

func test_reset_allows_completing_again() -> void:
	var objective := HitTargets.new()
	objective.target_ids = ["a", "b"]
	add_child_autofree(objective)

	objective.notify_target_hit("a")
	objective.notify_target_hit("b")
	assert_true(objective.is_complete())

	objective.reset()
	assert_false(objective.is_complete())

	watch_signals(objective)
	objective.notify_target_hit("a")
	objective.notify_target_hit("b")
	assert_signal_emitted(objective, "completed")
