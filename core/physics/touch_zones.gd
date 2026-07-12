extends CanvasLayer

## Full-screen left/right touch zones that mirror keyboard flipper input.
## Placeholder UI for §10a — no theme, just functional split-screen buttons.

@onready var _left_zone: TouchScreenButton = $LeftZone
@onready var _right_zone: TouchScreenButton = $RightZone

func _ready() -> void:
	_left_zone.pressed.connect(func(): Input.action_press("flip_left"))
	_left_zone.released.connect(func(): Input.action_release("flip_left"))
	_right_zone.pressed.connect(func(): Input.action_press("flip_right"))
	_right_zone.released.connect(func(): Input.action_release("flip_right"))
