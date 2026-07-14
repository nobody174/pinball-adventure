extends Area2D

## Standup-style target that visually "drops" on hit — fades and stops
## registering further hits until reset — rather than the flash-and-recover
## of standup_target.gd. Fits a "wall you break through" feel (e.g. Firewall
## Breach) better than a target that immediately springs back.

signal hit(target_id: String)

@export var target_id: String = ""
@export var down_color: Color = Color(0.15, 0.15, 0.17, 0.4)

var _base_color: Color
var _down: bool = false
@onready var _sprite: Polygon2D = $Sprite
@onready var _collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	_base_color = _sprite.color
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _down or not body is RigidBody2D:
		return
	_down = true
	_sprite.color = down_color
	_collision.set_deferred("disabled", true)
	hit.emit(target_id)

func reset_target() -> void:
	_down = false
	_sprite.color = _base_color
	_collision.set_deferred("disabled", false)

func is_down() -> bool:
	return _down
