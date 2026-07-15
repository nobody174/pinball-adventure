#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends Camera2D

## Scrolls vertically to follow the ball -- tables have grown far taller
## than a single screen (the shooter lane extension alone made the total
## table height exactly equal the viewport height, meaning the *entire*
## table was rendered in one static frame with no scrolling at all, far
## too small to actually see or play). Horizontal position stays fixed:
## the table width matches the viewport width exactly, so there's no
## meaningful room (or need) to scroll sideways.
##
## min_camera_y/max_camera_y clamp scrolling to the table's actual bounds,
## so the camera never reveals empty space beyond the top or bottom walls.

@export var target_path: NodePath
@export var min_camera_y: float = -875.0
@export var max_camera_y: float = 175.0

@onready var _target: Node2D = get_node(target_path)

func _process(_delta: float) -> void:
	global_position.y = clampf(_target.global_position.y, min_camera_y, max_camera_y)

# Built with assistance from Claude Code by Anthropic.
