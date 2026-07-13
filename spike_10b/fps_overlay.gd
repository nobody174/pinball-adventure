extends CanvasLayer

## §10b decision-gate readout — the actual number that matters for the
## performance spike. Not production UI.

@onready var _label: Label = $Label

func _process(_delta: float) -> void:
	_label.text = "FPS: %d" % Engine.get_frames_per_second()
