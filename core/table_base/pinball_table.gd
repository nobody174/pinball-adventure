extends Node2D
class_name PinballTable

## Base class every table extends (GDD §11). Theme-independent: knows how to
## route target hits to the objective system and how to react when the ball
## drains, but nothing about what a "shader node" or "sprite cache" is —
## that's table-specific config/content layered on top.

signal ball_lost
signal objective_completed(objective_id: String)

@onready var objectives: Node = $ObjectiveManager

func _ready() -> void:
	objectives.objective_completed.connect(func(id: String) -> void: objective_completed.emit(id))

## Called by any target/sensor node when the ball hits it, tagged with the
## id that objectives.json config refers to it by.
func register_target_hit(target_id: String) -> void:
	objectives.notify_target_hit(target_id)
