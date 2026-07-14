extends GutTest

const ObjectiveManagerScript := preload("res://core/objectives/objective_manager.gd")

func test_loads_hit_targets_config_and_emits_completion_with_config_id() -> void:
	var manager := Node.new()
	manager.set_script(ObjectiveManagerScript)
	add_child_autofree(manager)

	manager.load_from_config([
		{
			"id": "shader_rebuild",
			"type": "hit_targets",
			"target_ids": ["shader_a", "shader_b", "shader_c"],
			"require_order": true,
		},
	])

	watch_signals(manager)
	manager.notify_target_hit("shader_a")
	manager.notify_target_hit("shader_b")
	manager.notify_target_hit("shader_c")

	assert_signal_emitted_with_parameters(manager, "objective_completed", ["shader_rebuild"])

func test_unknown_objective_type_does_not_crash() -> void:
	var manager := Node.new()
	manager.set_script(ObjectiveManagerScript)
	add_child_autofree(manager)

	manager.load_from_config([{"id": "mystery", "type": "not_a_real_type"}])
	manager.notify_target_hit("anything")
	pass_test("loading an unknown objective type should warn, not crash")
