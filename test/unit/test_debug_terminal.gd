extends GutTest

const DebugTerminalScene := preload("res://core/ui/debug_terminal.tscn")

func _make_terminal() -> Control:
	var terminal: Control = DebugTerminalScene.instantiate()
	add_child_autofree(terminal)
	return terminal

func test_log_event_appears_in_label_text() -> void:
	var terminal := _make_terminal()
	terminal.log_event("hello")
	assert_true(terminal.get_node("Label").text.contains("hello"))

func test_trims_to_max_lines() -> void:
	var terminal := _make_terminal()
	terminal.max_lines = 3
	terminal.log_event("one")
	terminal.log_event("two")
	terminal.log_event("three")
	terminal.log_event("four")

	var text: String = terminal.get_node("Label").text
	assert_false(text.contains("one"), "oldest line should have been dropped")
	assert_true(text.contains("four"))

func test_clear_empties_the_log() -> void:
	var terminal := _make_terminal()
	terminal.log_event("something")
	terminal.clear()
	assert_eq(terminal.get_node("Label").text, "")
