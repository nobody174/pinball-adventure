extends Area2D

## Generic pinball slingshot: kicks the ball away in a fixed direction on
## contact (not radially outward like a bumper — the fixed direction plus
## the angled triangular shape is what makes a slingshot feel different
## from a bumper). Cooldown prevents a double-kick from one pass through.

signal kicked

@export var kick_direction: Vector2 = Vector2.UP
@export var kick_strength: float = 500.0
@export var kick_cooldown_seconds: float = 0.15
@export var flash_color: Color = Color(1, 1, 1, 1)

var _cooldown_remaining: float = 0.0
var _base_color: Color
@onready var _sprite: Polygon2D = $Sprite

func _ready() -> void:
	_base_color = _sprite.color
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	_cooldown_remaining = maxf(0.0, _cooldown_remaining - delta)

func _on_body_entered(body: Node2D) -> void:
	if not body is RigidBody2D or _cooldown_remaining > 0.0:
		return
	body.apply_central_impulse(kick_direction.normalized() * kick_strength)
	kicked.emit()
	_cooldown_remaining = kick_cooldown_seconds
	_flash()

func _flash() -> void:
	_sprite.color = flash_color
	await get_tree().create_timer(0.12).timeout
	_sprite.color = _base_color
