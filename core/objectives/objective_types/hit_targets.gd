extends Node
class_name HitTargetsObjective

## Generic reusable objective: hit a configured set of targets, optionally
## in a specific order, to complete. Individual tables never subclass this —
## they only configure target_ids/require_order via objectives.json (GDD §11:
## "Objectives are data, not code").

signal completed

var target_ids: Array = []
var require_order: bool = false

var _hit: Array = []

func notify_target_hit(target_id: String) -> void:
	if is_complete() or target_id not in target_ids:
		return
	if require_order:
		var expected_index: int = _hit.size()
		if expected_index >= target_ids.size() or target_ids[expected_index] != target_id:
			_hit.clear() ## Wrong-order hit resets progress — makes the sequence a real skill target.
			return
		_hit.append(target_id)
	elif target_id not in _hit:
		_hit.append(target_id)

	if _hit.size() >= target_ids.size():
		completed.emit()

func is_complete() -> bool:
	return _hit.size() >= target_ids.size()
