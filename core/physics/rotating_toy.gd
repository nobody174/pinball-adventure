extends Area2D

## Reusable rotating table toy: spins continuously, can be toggled "charged"
## externally (e.g. by an objective completing), and reports which state the
## ball hit it in. What "charged" means to a given table, and what happens
## on each kind of hit, is entirely up to that table — this script only
## knows spin + color + report.

signal hit_while_charged
signal hit_while_uncharged

@export var rotation_speed: float = 1.5 ## radians/sec
@export var charged_color: Color = Color(0.2, 1, 0.5, 1)
@export var uncharged_color: Color = Color(1, 0.2, 0.3, 1)

var charged: bool = false:
	set(value):
		charged = value
		_update_color()

@onready var _sprite: Polygon2D = $Sprite

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_color()

func _process(delta: float) -> void:
	rotation += rotation_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if not body is RigidBody2D:
		return
	if charged:
		hit_while_charged.emit()
	else:
		hit_while_uncharged.emit()

func _update_color() -> void:
	_sprite.color = charged_color if charged else uncharged_color
