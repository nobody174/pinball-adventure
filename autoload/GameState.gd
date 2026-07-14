#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends Node

## Session score + local high-score persistence. Deliberately a single
## autoload for now rather than the full core/progression/player_progress.gd
## + ProgressionService split GDD §11 proposes — that separation exists to
## give Phase 4+ server sync a seam to attach to, which doesn't matter yet.
## Split it out when that's actually true, not before.

signal score_changed(new_score: int)

const SAVE_PATH := "user://high_scores.json"

var score: int = 0

var _high_scores: Dictionary = {} # table_id -> int

func _ready() -> void:
	_load_high_scores()

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func reset_score() -> void:
	score = 0
	score_changed.emit(score)

func get_high_score(table_id: String) -> int:
	return _high_scores.get(table_id, 0)

## Call at the end of a ball/game. Returns true if this was a new high score.
func submit_score(table_id: String, final_score: int) -> bool:
	var previous: int = get_high_score(table_id)
	if final_score <= previous:
		return false
	_high_scores[table_id] = final_score
	_save_high_scores()
	return true

func _load_high_scores() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		_high_scores = parsed

func _save_high_scores() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(_high_scores))
	file.close()

# Built with assistance from Claude Code by Anthropic.
