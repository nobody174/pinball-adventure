extends GutTest

const RampLayerZoneScript := preload("res://core/physics/ramp_layer_zone.gd")

func _make_zone(target_mask: int) -> Area2D:
	var zone := Area2D.new()
	zone.set_script(RampLayerZoneScript)
	zone.target_collision_mask = target_mask
	add_child_autofree(zone)
	return zone

func test_sets_ball_collision_mask_on_entry() -> void:
	var zone := _make_zone(1 | 2) ## default (layer 1) + ramp A (layer 2)
	var ball := RigidBody2D.new()
	ball.collision_mask = 1
	add_child_autofree(ball)

	zone._on_body_entered(ball)

	assert_eq(ball.collision_mask, 3)

func test_exit_zone_restores_default_mask() -> void:
	var entrance := _make_zone(1 | 2)
	var exit_zone := _make_zone(1)
	var ball := RigidBody2D.new()
	ball.collision_mask = 1
	add_child_autofree(ball)

	entrance._on_body_entered(ball)
	assert_eq(ball.collision_mask, 3)

	exit_zone._on_body_entered(ball)
	assert_eq(ball.collision_mask, 1)

func test_ignores_non_rigidbody() -> void:
	var zone := _make_zone(1 | 2)
	var node: Node2D = autofree(Node2D.new())

	zone._on_body_entered(node)

	assert_true(true) ## No crash/error on a non-RigidBody2D is the assertion here.
