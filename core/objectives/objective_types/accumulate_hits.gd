#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends Node
class_name AccumulateHitsObjective

## Generic reusable objective: hit any of a configured set of targets,
## repeatedly, until a total-hit threshold is reached — order doesn't
## matter, and the same target counts every time. A build-up/charge
## mechanic, distinct from HitTargetsObjective's "each target once, maybe
## in a specific order" sequence.

signal completed
signal progressed(hit_count: int, threshold: int)

var target_ids: Array = []
var threshold: int = 1

var _hit_count: int = 0

func notify_target_hit(target_id: String) -> void:
	if is_complete() or target_id not in target_ids:
		return
	_hit_count += 1
	progressed.emit(_hit_count, threshold)
	if _hit_count >= threshold:
		completed.emit()

func is_complete() -> bool:
	return _hit_count >= threshold

## Charge-style objectives are typically meant to repeat (unlike a one-shot
## sequence) — the table decides when to call this, not this script.
func reset() -> void:
	_hit_count = 0

# Built with assistance from Claude Code by Anthropic.
