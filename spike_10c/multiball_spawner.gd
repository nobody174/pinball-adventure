#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends Node2D

## Spike 10c probe: spawns extra_ball_count additional balls (on top of the
## one already in physics_prototype.tscn) at staggered launch-lane positions
## with real upward velocity, to stress-test tunneling/jitter under genuine
## multi-ball contention against the existing flipper/bumper/ramp geometry --
## not just raw body count, which Godot's 2D physics handles trivially.

const BallScript := preload("res://core/physics/ball.gd")

@export var extra_ball_count: int = 5
@export var spawn_position: Vector2 = Vector2(423, 400)
@export var launch_velocity: Vector2 = Vector2(0, -1400)
@export var spawn_interval_seconds: float = 0.15

func _ready() -> void:
	for i in range(extra_ball_count):
		var t := Timer.new()
		t.wait_time = spawn_interval_seconds * (i + 1)
		t.one_shot = true
		t.autostart = true
		t.timeout.connect(_spawn_ball.bind(t))
		add_child(t)

func _spawn_ball(t: Timer) -> void:
	t.queue_free()
	var ball := RigidBody2D.new()
	ball.set_script(BallScript)
	ball.position = spawn_position + Vector2(randf_range(-10, 10), 0)
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 14.0
	collision.shape = shape
	ball.add_child(collision)
	get_parent().add_child(ball)
	ball.apply_central_impulse(launch_velocity)

# Built with assistance from Claude Code by Anthropic.
