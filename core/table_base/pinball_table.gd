#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends Node2D
class_name PinballTable

## Base class every table extends (GDD §11). Theme-independent: knows how to
## route target hits to the objective system and how to react when the ball
## drains, but nothing about what a "shader node" or "sprite cache" is —
## that's table-specific config/content layered on top.

signal ball_lost
signal objective_completed(objective_id: String)
signal objective_sequence_reset(objective_id: String)
signal multiball_ball_released(balls_remaining: int)
signal multiball_ready

const BallScript := preload("res://core/physics/ball.gd")
const _MULTIBALL_BALL_RADIUS := 14.0 ## Matches the radius already tuned on the table's main ball (physics_prototype.tscn).

@onready var objectives: Node = $ObjectiveManager
@onready var input_log: InputLog = $InputLog

var _multiball_queue_remaining: int = 0
var _multiball_release_timer: Timer

func _ready() -> void:
	objectives.objective_completed.connect(func(id: String) -> void: objective_completed.emit(id))
	objectives.objective_sequence_reset.connect(func(id: String) -> void: objective_sequence_reset.emit(id))
	input_log.start_recording()
	_multiball_release_timer = Timer.new()
	_multiball_release_timer.one_shot = true
	_multiball_release_timer.timeout.connect(_release_next_queued_ball)
	add_child(_multiball_release_timer)

## Queues extra_ball_count additional balls, released one at a time on
## release_interval_seconds rather than all at once -- spawning several
## RigidBody2D balls into the same physics step in the same spot is a real
## way to produce unstable, overlapping-shape contacts on the very first
## frame. Each released ball spawns at spawn_position with launch_velocity,
## same shape as the existing single-ball plunger launch, just repeated.
## Table code decides *when* to call this (e.g. on completing a mode) --
## this only handles the *mechanics* of releasing them safely.
func start_multiball(extra_ball_count: int, spawn_position: Vector2, launch_velocity: Vector2, release_interval_seconds: float = 0.4) -> void:
	_multiball_queue_remaining = extra_ball_count
	_multiball_spawn_position = spawn_position
	_multiball_launch_velocity = launch_velocity
	_multiball_release_timer.wait_time = release_interval_seconds
	_release_next_queued_ball()

var _multiball_spawn_position: Vector2
var _multiball_launch_velocity: Vector2

func _release_next_queued_ball() -> void:
	if _multiball_queue_remaining <= 0:
		return
	var ball := RigidBody2D.new()
	ball.set_script(BallScript)
	ball.position = _multiball_spawn_position
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = _MULTIBALL_BALL_RADIUS
	collision.shape = shape
	ball.add_child(collision)
	add_child(ball)
	register_ball(ball)
	ball.apply_central_impulse(_multiball_launch_velocity)
	_multiball_queue_remaining -= 1
	multiball_ball_released.emit(_multiball_queue_remaining)
	if _multiball_queue_remaining > 0:
		_multiball_release_timer.start()
	else:
		multiball_ready.emit()

## Wires a ball's own `drained` signal to this table's `ball_lost` (a table
## can have several balls at once during multiball, so this can't just be a
## single fixed @onready reference) -- call once per ball a table spawns,
## including its main plunger-lane ball.
func register_ball(ball: PinballBall) -> void:
	ball.drained.connect(func() -> void: ball_lost.emit())

## Called by any target/sensor node when the ball hits it, tagged with the
## id that the table's objective config (see objective_manager.gd) refers
## to it by.
func register_target_hit(target_id: String) -> void:
	objectives.notify_target_hit(target_id)

## Wires a group of hit-reporting nodes (targets/bumpers/lanes/etc.) to the
## common scoring + objective-system pattern in one call, instead of
## hand-duplicating "add_score + register_target_hit [+ log]" per node
## across every table that has this shape of content.
func wire_hit_group(nodes: Array, points: int, on_hit: Callable = Callable()) -> void:
	for node in nodes:
		node.hit.connect(func(id: String) -> void:
			GameState.add_score(points)
			register_target_hit(id)
			if on_hit.is_valid():
				on_hit.call(id)
		)

# Built with assistance from Claude Code by Anthropic.
