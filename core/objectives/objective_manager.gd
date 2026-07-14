extends Node

## Reads a table's objective config (array of dicts — normally loaded from
## that table's objectives.json, GDD §6) and instantiates the matching
## objective_type for each entry. Theme-independent: has no idea what any
## objective_id/target_id string actually means to a table.

signal objective_completed(objective_id: String)
signal objective_sequence_reset(objective_id: String)

const HitTargets := preload("res://core/objectives/objective_types/hit_targets.gd")
const AccumulateHits := preload("res://core/objectives/objective_types/accumulate_hits.gd")

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
				objective.sequence_reset.connect(func() -> void: objective_sequence_reset.emit(objective_id))
				_objectives[objective_id] = objective
				add_child(objective)
			"accumulate_hits":
				var objective := AccumulateHits.new()
				objective.target_ids = entry.get("target_ids", [])
				objective.threshold = entry.get("threshold", 1)
				objective.completed.connect(func() -> void: objective_completed.emit(objective_id))
				_objectives[objective_id] = objective
				add_child(objective)
			_:
				push_warning("ObjectiveManager: unknown objective type '%s'" % entry.get("type", ""))

func notify_target_hit(target_id: String) -> void:
	for objective in _objectives.values():
		objective.notify_target_hit(target_id)

## Lets a table reach into a specific objective — used for things the
## generic manager interface doesn't cover, like resetting a repeatable
## charge-style objective after it completes.
func get_objective(objective_id: String) -> Node:
	return _objectives.get(objective_id)
