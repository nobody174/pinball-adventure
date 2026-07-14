#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends Node
class_name InputLog

## Records timestamped flipper/nudge/launch input events during play, per
## GDD §6/§7: the input log (not the score itself) is what Phase 4's
## server-side verification re-simulates and checks against a submitted
## score. Capturing this now — while every table is still new — means it
## exists when Phase 4 needs it, instead of retrofitting every table later.
## v1 only captures and holds the log locally; nothing uploads or persists
## it yet, since there's no server to send it to and no Phase 4 schema to
## match — that's explicitly future work, not scope creep to build now.

const TRACKED_ACTIONS := ["flip_left", "flip_right", "nudge", "launch_ball"]

var _events: Array = []
var _recording: bool = false
var _elapsed: float = 0.0

func start_recording() -> void:
	_events.clear()
	_elapsed = 0.0
	_recording = true

func stop_recording() -> void:
	_recording = false

func is_recording() -> bool:
	return _recording

## Exposed separately from _process's Input polling so tests can drive it
## directly without needing real Input state.
func record_event(action: String, pressed: bool) -> void:
	if not _recording:
		return
	_events.append({"t": _elapsed, "action": action, "pressed": pressed})

func get_log() -> Array:
	return _events.duplicate(true)

func _process(delta: float) -> void:
	if not _recording:
		return
	_elapsed += delta
	for action in TRACKED_ACTIONS:
		if Input.is_action_just_pressed(action):
			record_event(action, true)
		elif Input.is_action_just_released(action):
			record_event(action, false)

# Built with assistance from Claude Code by Anthropic.
