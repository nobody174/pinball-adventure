extends Area2D

## Generic spinner: a free-swinging vane the ball pushes through. Emits its
## own id on each pass (same convention as standup_target.gd) so tables can
## wire it into whatever scoring/objective they want. The visual spin is
## purely cosmetic feedback -- collision is a thin static Area2D, not an
## actual simulated hinge, since a spinner's gameplay role is "fast repeat
## trigger", not physical accuracy.

signal spun(target_id: String)

@export var target_id: String = ""
@export var spin_duration_seconds: float = 0.2

var _spinning: bool = false
@onready var _sprite: Polygon2D = $Sprite

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body is RigidBody2D:
		return
	spun.emit(target_id)
	_play_spin()

func _play_spin() -> void:
	if _spinning:
		return
	_spinning = true
	var tween := create_tween()
	tween.tween_property(_sprite, "rotation", _sprite.rotation + TAU, spin_duration_seconds)
	await tween.finished
	_spinning = false
