extends GutTest

const CollapsingBridgeScript := preload("res://core/physics/collapsing_bridge.gd")

func _make_bridge() -> StaticBody2D:
	var bridge := StaticBody2D.new()
	bridge.set_script(CollapsingBridgeScript)
	bridge.collapse_duration_seconds = 0.05
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.shape = RectangleShape2D.new()
	bridge.add_child(collision)
	var sprite := Polygon2D.new()
	sprite.name = "Sprite"
	bridge.add_child(sprite)
	add_child_autofree(bridge)
	return bridge

func test_starts_solid() -> void:
	var bridge := _make_bridge()
	assert_false(bridge._collision.disabled, "bridge should be solid (collision enabled) by default")

func test_trigger_collapse_disables_collision_and_emits_collapsed() -> void:
	var bridge := _make_bridge()
	watch_signals(bridge)

	bridge.trigger_collapse()
	await wait_physics_frames(2)

	assert_true(bridge._collision.disabled, "collision should be disabled while collapsed")
	assert_signal_emitted(bridge, "collapsed")

func test_resets_after_duration() -> void:
	var bridge := _make_bridge()
	watch_signals(bridge)

	bridge.trigger_collapse()
	await wait_seconds(0.1)

	assert_false(bridge._collision.disabled, "bridge should be solid again after collapse_duration_seconds")
	assert_signal_emitted(bridge, "reset")

func test_trigger_collapse_while_already_collapsed_is_ignored() -> void:
	var bridge := _make_bridge()
	bridge.trigger_collapse()
	watch_signals(bridge)

	bridge.trigger_collapse()

	assert_signal_not_emitted(bridge, "collapsed", "a second trigger mid-collapse shouldn't restart the timer")
