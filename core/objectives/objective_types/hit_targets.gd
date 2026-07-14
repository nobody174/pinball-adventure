extends Node
class_name HitTargetsObjective

## Generic reusable objective: hit a configured set of targets, optionally
## in a specific order, to complete. Individual tables never subclass this —
## they only configure target_ids/require_order via objectives.json (GDD §11:
## "Objectives are data, not code").

signal completed
signal sequence_reset ## Wrong-order hit while progress existed — table layer should give feedback, not leave it silent.
signal progressed(hit_count: int, total: int)

var target_ids: Array = []
var require_order: bool = false

var _hit: Array = []

func notify_target_hit(target_id: String) -> void:
	if is_complete() or target_id not in target_ids:
		return
	if require_order:
		var expected_index: int = _hit.size()
		if expected_index >= target_ids.size() or target_ids[expected_index] != target_id:
			var had_progress: bool = not _hit.is_empty()
			_hit.clear() ## Wrong-order hit resets progress — makes the sequence a real skill target.
			if had_progress:
				sequence_reset.emit()
			return
		_hit.append(target_id)
	elif target_id not in _hit:
		_hit.append(target_id)

	progressed.emit(_hit.size(), target_ids.size())
	if _hit.size() >= target_ids.size():
		completed.emit()

func is_complete() -> bool:
	return _hit.size() >= target_ids.size()
