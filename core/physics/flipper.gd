extends RigidBody2D

## Placeholder flipper. One instance per flipper; `is_left` mirrors input/rotation direction.
## Tunable in the inspector for §10a feel-testing.

@export var is_left: bool = true
## Positive = rotated clockwise on screen (Y-down). Rest droops the tip down
## and toward the pivot (reduces reach/overlap); active swings it up.
@export var rest_angle_degrees: float = 25.0
@export var active_angle_degrees: float = -25.0
@export var torque_strength: float = 900000.0
@export var damping_strength: float = 40000.0
@export var input_action: String = "flip_left"

var _rest_angle: float
var _active_angle: float
var _pressed: bool = false

func _ready() -> void:
	lock_rotation = false
	gravity_scale = 0.0
	## Pin torque rotates around the body's center of mass, not the node origin.
	## The collision shape is offset from the pivot, so without this the flipper
	## drifts instead of spinning in place — force the CoM back to the pivot.
	center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = Vector2.ZERO
	_rest_angle = deg_to_rad(rest_angle_degrees) * (1.0 if is_left else -1.0)
	_active_angle = deg_to_rad(active_angle_degrees) * (1.0 if is_left else -1.0)
	rotation = _rest_angle

func _physics_process(_delta: float) -> void:
	_pressed = Input.is_action_pressed(input_action)
	var target_angle: float = _active_angle if _pressed else _rest_angle
	var angle_diff: float = wrapf(target_angle - rotation, -PI, PI)
	## PD control: spring term (torque_strength) snaps to target, damping term
	## (damping_strength) resists angular velocity to prevent ringing/overshoot
	## at high torque values.
	apply_torque(angle_diff * torque_strength - angular_velocity * damping_strength)
