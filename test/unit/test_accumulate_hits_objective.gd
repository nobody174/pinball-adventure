extends GutTest

const AccumulateHits := preload("res://core/objectives/objective_types/accumulate_hits.gd")

func test_completes_when_threshold_reached_any_order() -> void:
	var objective := AccumulateHits.new()
	objective.target_ids = ["a", "b", "c"]
	objective.threshold = 3
	add_child_autofree(objective)

	watch_signals(objective)
	objective.notify_target_hit("a")
	objective.notify_target_hit("a") ## Same target repeatedly is fine -- it's a charge, not a sequence.
	objective.notify_target_hit("c")

	assert_signal_emitted(objective, "completed")
	assert_true(objective.is_complete())

func test_does_not_complete_before_threshold() -> void:
	var objective := AccumulateHits.new()
	objective.target_ids = ["a", "b"]
	objective.threshold = 5
	add_child_autofree(objective)

	watch_signals(objective)
	objective.notify_target_hit("a")
	objective.notify_target_hit("b")

	assert_signal_not_emitted(objective, "completed")
	assert_false(objective.is_complete())

func test_unknown_target_does_not_count() -> void:
	var objective := AccumulateHits.new()
	objective.target_ids = ["a"]
	objective.threshold = 1
	add_child_autofree(objective)

	watch_signals(objective)
	objective.notify_target_hit("not_in_the_set")

	assert_signal_not_emitted(objective, "completed")

func test_reset_allows_completing_again() -> void:
	var objective := AccumulateHits.new()
	objective.target_ids = ["a"]
	objective.threshold = 1
	add_child_autofree(objective)

	objective.notify_target_hit("a")
	assert_true(objective.is_complete())

	objective.reset()
	assert_false(objective.is_complete())

	watch_signals(objective)
	objective.notify_target_hit("a")
	assert_signal_emitted(objective, "completed")

func test_hits_past_threshold_do_not_re_emit_completed() -> void:
	var objective := AccumulateHits.new()
	objective.target_ids = ["a"]
	objective.threshold = 1
	add_child_autofree(objective)

	objective.notify_target_hit("a")
	watch_signals(objective)
	objective.notify_target_hit("a") ## Already complete -- should be a no-op until reset().

	assert_signal_not_emitted(objective, "completed")
