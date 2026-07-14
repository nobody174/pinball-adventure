extends Control
class_name DebugTerminal

## Small scrolling event log — generic across tables (first real piece of
## core/ui/'s planned responsive HUD framework, kept deliberately minimal:
## just this one reusable widget, not a whole system built ahead of need).
## Styling (font/colors) is set on the Label itself per table/theme.

@export var max_lines: int = 6

var _lines: Array = []
@onready var _label: Label = $Label

func log_event(text: String) -> void:
	_lines.append(text)
	if _lines.size() > max_lines:
		_lines.pop_front()
	_label.text = "\n".join(_lines)

func clear() -> void:
	_lines.clear()
	_label.text = ""
