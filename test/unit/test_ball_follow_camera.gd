extends GutTest

const BallFollowCameraScript := preload("res://core/physics/ball_follow_camera.gd")

func _make_camera(target: Node2D) -> Camera2D:
	add_child_autofree(target)
	var cam := Camera2D.new()
	cam.set_script(BallFollowCameraScript)
	cam.min_camera_y = -875.0
	cam.max_camera_y = 175.0
	cam.target_path = target.get_path() ## Absolute path -- cam itself isn't in the tree yet, get_path_to needs both nodes in-tree.
	add_child_autofree(cam)
	return cam

func test_follows_target_within_bounds() -> void:
	var target := Node2D.new()
	target.global_position = Vector2(225, -400)
	var cam := _make_camera(target)

	cam._process(0.0)

	assert_almost_eq(cam.global_position.y, -400.0, 0.5)

func test_clamps_at_top_bound() -> void:
	var target := Node2D.new()
	target.global_position = Vector2(225, -2000) ## Well past the top of the table.
	var cam := _make_camera(target)

	cam._process(0.0)

	assert_almost_eq(cam.global_position.y, -875.0, 0.5, "camera should not scroll past the table's top wall")

func test_clamps_at_bottom_bound() -> void:
	var target := Node2D.new()
	target.global_position = Vector2(225, 900) ## Well past the bottom of the table.
	var cam := _make_camera(target)

	cam._process(0.0)

	assert_almost_eq(cam.global_position.y, 175.0, 0.5, "camera should not scroll past the table's bottom wall")
