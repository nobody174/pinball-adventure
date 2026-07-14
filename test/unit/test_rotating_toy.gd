extends GutTest

const RotatingToyScene := preload("res://core/physics/rotating_toy.gd")

func _make_toy() -> Area2D:
	var toy := Area2D.new()
	toy.set_script(RotatingToyScene)
	var sprite := Polygon2D.new()
	sprite.name = "Sprite"
	toy.add_child(sprite)
	add_child_autofree(toy)
	return toy

func test_starts_uncharged_with_uncharged_color() -> void:
	var toy := _make_toy()
	assert_false(toy.charged)
	assert_eq(toy.get_node("Sprite").color, toy.uncharged_color)

func test_setting_charged_updates_sprite_color() -> void:
	var toy := _make_toy()
	toy.charged = true
	assert_eq(toy.get_node("Sprite").color, toy.charged_color)

func test_body_entered_emits_hit_while_charged_when_charged() -> void:
	var toy := _make_toy()
	toy.charged = true
	watch_signals(toy)
	toy._on_body_entered(autofree(RigidBody2D.new()))
	assert_signal_emitted(toy, "hit_while_charged")
	assert_signal_not_emitted(toy, "hit_while_uncharged")

func test_body_entered_emits_hit_while_uncharged_when_not_charged() -> void:
	var toy := _make_toy()
	watch_signals(toy)
	toy._on_body_entered(autofree(RigidBody2D.new()))
	assert_signal_emitted(toy, "hit_while_uncharged")
	assert_signal_not_emitted(toy, "hit_while_charged")

func test_non_rigidbody_does_not_trigger_hit() -> void:
	var toy := _make_toy()
	watch_signals(toy)
	toy._on_body_entered(autofree(Node2D.new()))
	assert_signal_not_emitted(toy, "hit_while_charged")
	assert_signal_not_emitted(toy, "hit_while_uncharged")
