extends GutTest

const InputLogScript := preload("res://core/replay/input_log.gd")

func _make_log() -> Node:
	var log_node := Node.new()
	log_node.set_script(InputLogScript)
	add_child_autofree(log_node)
	return log_node

func test_not_recording_by_default() -> void:
	var log_node := _make_log()
	assert_false(log_node.is_recording())

func test_start_recording_captures_events() -> void:
	var log_node := _make_log()
	log_node.start_recording()
	log_node.record_event("flip_left", true)
	log_node.record_event("flip_left", false)

	var log: Array = log_node.get_log()
	assert_eq(log.size(), 2)
	assert_eq(log[0]["action"], "flip_left")
	assert_eq(log[0]["pressed"], true)
	assert_eq(log[1]["pressed"], false)

func test_events_ignored_when_not_recording() -> void:
	var log_node := _make_log()
	log_node.record_event("flip_left", true) ## Never started -- should be a no-op.
	assert_eq(log_node.get_log().size(), 0)

func test_stop_recording_stops_capturing_new_events() -> void:
	var log_node := _make_log()
	log_node.start_recording()
	log_node.record_event("flip_left", true)
	log_node.stop_recording()
	log_node.record_event("flip_right", true)

	assert_eq(log_node.get_log().size(), 1)
	assert_false(log_node.is_recording())

func test_start_recording_again_clears_previous_log() -> void:
	var log_node := _make_log()
	log_node.start_recording()
	log_node.record_event("flip_left", true)
	log_node.start_recording() ## Starting a new session should discard the old one.

	assert_eq(log_node.get_log().size(), 0)

func test_get_log_returns_a_copy_not_the_internal_array() -> void:
	var log_node := _make_log()
	log_node.start_recording()
	log_node.record_event("flip_left", true)

	var log: Array = log_node.get_log()
	log.clear()

	assert_eq(log_node.get_log().size(), 1, "mutating the returned log shouldn't affect internal state")
