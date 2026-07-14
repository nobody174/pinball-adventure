extends GutTest

const DropTargetScript := preload("res://core/physics/drop_target.gd")

func _make_target() -> Area2D:
	var target := Area2D.new()
	target.set_script(DropTargetScript)
	target.target_id = "fw_a"
	var sprite := Polygon2D.new()
	sprite.name = "Sprite"
	sprite.color = Color(1, 1, 1, 1)
	target.add_child(sprite)
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	target.add_child(collision)
	add_child_autofree(target)
	return target

func test_starts_up() -> void:
	var target := _make_target()
	assert_false(target.is_down())

func test_hit_drops_the_target_and_reports_its_id() -> void:
	var target := _make_target()
	watch_signals(target)

	target._on_body_entered(autofree(RigidBody2D.new()))

	assert_true(target.is_down())
	assert_signal_emitted_with_parameters(target, "hit", ["fw_a"])
	assert_eq(target.get_node("Sprite").color, target.down_color)

func test_hit_while_already_down_does_not_re_emit() -> void:
	var target := _make_target()
	target._on_body_entered(autofree(RigidBody2D.new()))
	watch_signals(target)

	target._on_body_entered(autofree(RigidBody2D.new()))

	assert_signal_not_emitted(target, "hit")

func test_reset_target_pops_it_back_up() -> void:
	var target := _make_target()
	target._on_body_entered(autofree(RigidBody2D.new()))

	target.reset_target()

	assert_false(target.is_down())
	assert_eq(target.get_node("Sprite").color, Color(1, 1, 1, 1))

func test_non_rigidbody_does_not_drop_it() -> void:
	var target := _make_target()
	watch_signals(target)

	target._on_body_entered(autofree(Node2D.new()))

	assert_signal_not_emitted(target, "hit")
	assert_false(target.is_down())
