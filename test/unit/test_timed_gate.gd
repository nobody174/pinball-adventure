extends GutTest

const TimedGateScript := preload("res://core/physics/timed_gate.gd")

func _make_gate() -> StaticBody2D:
	var gate := StaticBody2D.new()
	gate.set_script(TimedGateScript)
	gate.open_duration_seconds = 0.05
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.shape = RectangleShape2D.new()
	gate.add_child(collision)
	var sprite := Polygon2D.new()
	sprite.name = "Sprite"
	gate.add_child(sprite)
	add_child_autofree(gate)
	return gate

func test_starts_closed() -> void:
	var gate := _make_gate()
	assert_false(gate._collision.disabled, "gate should block by default (collision enabled)")

func test_trigger_open_disables_collision_and_emits_opened() -> void:
	var gate := _make_gate()
	watch_signals(gate)

	gate.trigger_open()

	assert_true(gate._collision.disabled, "collision should be disabled while open")
	assert_signal_emitted(gate, "opened")

func test_closes_again_after_duration() -> void:
	var gate := _make_gate()
	watch_signals(gate)

	gate.trigger_open()
	await wait_seconds(0.1)

	assert_false(gate._collision.disabled, "gate should re-block after open_duration_seconds")
	assert_signal_emitted(gate, "closed")

func test_trigger_open_while_already_open_is_ignored() -> void:
	var gate := _make_gate()
	gate.trigger_open()
	watch_signals(gate)

	gate.trigger_open()

	assert_signal_not_emitted(gate, "opened", "a second trigger mid-open shouldn't restart the timer")
