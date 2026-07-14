extends Node

## Reads a table's objective config (array of dicts — normally loaded from
## that table's objectives.json, GDD §6) and instantiates the matching
## objective_type for each entry. Theme-independent: has no idea what any
## objective_id/target_id string actually means to a table.

signal objective_completed(objective_id: String)

const HitTargets := preload("res://core/objectives/objective_types/hit_targets.gd")

var _objectives: Dictionary = {}

func load_from_config(config: Array) -> void:
	for entry in config:
		var objective_id: String = entry.get("id", "")
		match entry.get("type", ""):
			"hit_targets":
				var objective := HitTargets.new()
				objective.target_ids = entry.get("target_ids", [])
				objective.require_order = entry.get("require_order", false)
				objective.completed.connect(func() -> void: objective_completed.emit(objective_id))
				_objectives[objective_id] = objective
				add_child(objective)
			_:
				push_warning("ObjectiveManager: unknown objective type '%s'" % entry.get("type", ""))

func notify_target_hit(target_id: String) -> void:
	for objective in _objectives.values():
		objective.notify_target_hit(target_id)
