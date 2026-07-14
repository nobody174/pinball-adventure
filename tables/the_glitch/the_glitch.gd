extends PinballTable

## The Glitch — vertical slice. Table-specific wiring only: what "shader_a/
## b/c" mean and what happens when the objective completes. The objective
## system itself (core/objectives/) has no idea any of this exists.

const SHADER_A := "shader_a"
const SHADER_B := "shader_b"
const SHADER_C := "shader_c"

@onready var _feedback_label: Label = $Feedback/Label

func _ready() -> void:
	super._ready()
	objectives.load_from_config([
		{
			"id": "shader_rebuild",
			"type": "hit_targets",
			"target_ids": [SHADER_A, SHADER_B, SHADER_C],
			"require_order": true,
		},
	])
	objective_completed.connect(_on_objective_completed)
	for target in $ShaderNodeTargets.get_children():
		target.hit.connect(register_target_hit)

func _on_objective_completed(objective_id: String) -> void:
	if objective_id == "shader_rebuild":
		_show_feedback("SHADER REBUILD COMPLETE")

func _show_feedback(text: String) -> void:
	_feedback_label.text = text
	_feedback_label.visible = true
	await get_tree().create_timer(2.0).timeout
	_feedback_label.visible = false
