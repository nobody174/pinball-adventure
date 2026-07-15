extends GutTest

const SubwayTunnelScript := preload("res://core/physics/subway_tunnel.gd")
const BallScript := preload("res://core/physics/ball.gd")

func _make_exit_marker(pos: Vector2) -> Node2D:
	var marker := Node2D.new()
	marker.name = "ExitMarker"
	marker.global_position = pos
	add_child_autofree(marker)
	return marker

func _make_tunnel(exit_node: Node2D) -> Area2D:
	var tunnel := Area2D.new()
	tunnel.set_script(SubwayTunnelScript)
	tunnel.target_id = "subway_a"
	tunnel.exit_velocity = Vector2(0, 500)
	## exit_point must be set before this node is added -- @onready resolves
	## get_node() at _ready(), same ordering a real .tscn instance would
	## have via its exported property values. Absolute path since tunnel
	## itself isn't in the tree yet (get_path_to needs both nodes in-tree).
	tunnel.exit_point = exit_node.get_path()
	add_child_autofree(tunnel)
	return tunnel

func _make_ball() -> RigidBody2D:
	var ball := RigidBody2D.new()
	ball.set_script(BallScript)
	var sprite := Polygon2D.new()
	sprite.name = "Sprite"
	ball.add_child(sprite)
	add_child_autofree(ball)
	return ball

func test_teleports_ball_to_exit_point_with_exit_velocity() -> void:
	var exit_marker := _make_exit_marker(Vector2(300, -900))
	var tunnel := _make_tunnel(exit_marker)
	var ball := _make_ball()
	ball.global_position = Vector2(50, 50)

	tunnel._on_body_entered(ball)
	await wait_physics_frames(1) ## Teleport applies in _integrate_forces; check before exit_velocity + gravity move it further.

	assert_almost_eq(ball.global_position.x, 300.0, 1.0)
	assert_almost_eq(ball.global_position.y, -900.0, 15.0)
	assert_almost_eq(ball.linear_velocity.y, 500.0, 20.0)

func test_emits_entered_with_target_id() -> void:
	var exit_marker := _make_exit_marker(Vector2(0, 0))
	var tunnel := _make_tunnel(exit_marker)
	var ball := _make_ball()
	watch_signals(tunnel)

	tunnel._on_body_entered(ball)

	assert_signal_emitted_with_parameters(tunnel, "entered", ["subway_a"])

func test_non_rigidbody_is_ignored() -> void:
	var exit_marker := _make_exit_marker(Vector2(0, 0))
	var tunnel := _make_tunnel(exit_marker)
	watch_signals(tunnel)

	tunnel._on_body_entered(autofree(Node2D.new()))

	assert_signal_not_emitted(tunnel, "entered")
