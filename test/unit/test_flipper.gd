extends GutTest

## Regression coverage for the rest/active angle mirroring bug fixed during
## §10a playtesting (rest must droop down, active must swing up, and the
## is_left mirror must produce symmetric behavior for both flippers).

const FlipperScript := preload("res://core/physics/flipper.gd")

func test_left_flipper_rests_drooped_down() -> void:
	var flipper := RigidBody2D.new()
	flipper.set_script(FlipperScript)
	flipper.is_left = true
	flipper.rest_angle_degrees = 25.0
	flipper.active_angle_degrees = -35.0
	add_child_autofree(flipper)
	await wait_physics_frames(1)
	assert_almost_eq(flipper.rotation, deg_to_rad(25.0), 0.01, "left flipper should rest at +25 degrees (drooped down)")

func test_right_flipper_mirrors_left() -> void:
	var left := RigidBody2D.new()
	left.set_script(FlipperScript)
	left.is_left = true
	add_child_autofree(left)

	var right := RigidBody2D.new()
	right.set_script(FlipperScript)
	right.is_left = false
	add_child_autofree(right)

	await wait_physics_frames(1)
	assert_almost_eq(right.rotation, -left.rotation, 0.01, "right flipper's rest rotation should mirror the left flipper's")

func test_swing_moves_toward_active_angle_when_pressed() -> void:
	var flipper := RigidBody2D.new()
	flipper.set_script(FlipperScript)
	flipper.is_left = true
	flipper.rest_angle_degrees = 25.0
	flipper.active_angle_degrees = -35.0
	flipper.swing_duration_seconds = 0.1
	flipper.input_action = "flip_left"
	add_child_autofree(flipper)

	var rest_rotation := flipper.rotation
	Input.action_press("flip_left")
	await wait_physics_frames(10)
	Input.action_release("flip_left")

	assert_lt(flipper.rotation, rest_rotation, "pressing the flipper should rotate it toward the (more negative) active angle, not further down")
