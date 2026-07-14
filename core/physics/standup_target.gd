extends Area2D

## Generic standup target: flashes on contact and reports its own id to
## whatever's listening. What that id means (part of a sequence, a bonus,
## etc.) is entirely up to the table/objective config, not this script.

signal hit(target_id: String)

@export var target_id: String = ""
@export var flash_color: Color = Color(1, 1, 1, 1)

var _base_color: Color
@onready var _sprite: Polygon2D = $Sprite

func _ready() -> void:
	_base_color = _sprite.color
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body is RigidBody2D:
		return
	hit.emit(target_id)
	_flash()

func _flash() -> void:
	_sprite.color = flash_color
	await get_tree().create_timer(0.15).timeout
	_sprite.color = _base_color
