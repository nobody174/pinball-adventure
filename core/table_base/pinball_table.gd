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

@onready var objectives: Node = $ObjectiveManager
@onready var input_log: InputLog = $InputLog

func _ready() -> void:
	objectives.objective_completed.connect(func(id: String) -> void: objective_completed.emit(id))
	objectives.objective_sequence_reset.connect(func(id: String) -> void: objective_sequence_reset.emit(id))
	input_log.start_recording()

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
