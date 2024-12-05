class_name XRToolsMovementFlight
extends XRToolsMovementProvider


signal flight_started()
signal flight_finished()

## Enumeration of controller to use for flight
enum FlightController {
	LEFT,		## Use left controller
	RIGHT,		## Use right controler
}


@export var order : int = 30
@export var controller : FlightController = FlightController.LEFT
@export var flight_button : String = "by_button"
@export var exclusive : bool = true

var _flight_button : bool = false
var _controller : XRController3D

## Flight Parameters
@export var flying_speed: float = 5.0
@export var air_resistance: float = 0.05
@export var max_speed: float = 40.0
@export var gravity: float = -11.2
@export var toggle:bool = true

var is_flying: bool = false
var reference_position: Vector3 = Vector3.ZERO
var current_velocity: Vector3 = Vector3.ZERO

@onready var _camera := XRHelpers.get_xr_camera(self)
@onready var _left_controller := XRHelpers.get_left_controller(self)
@onready var _right_controller := XRHelpers.get_right_controller(self)

var XROrigin: XROrigin3D = $"../.."
var XRCamera: XRCamera3D = $"../../XRCamera3D"
@export var XROriginPath: NodePath = "../../"
@export var XRCameraPath: NodePath = "../../XRCamera3D"

func _ready():
	super()
	# Initialize the correct controller
	if controller == FlightController.LEFT:
		_controller = _left_controller
	else:
		_controller = _right_controller


	if Engine.is_editor_hint():
		print("Running in the editor")
		call_deferred("_initialize_nodes")
	else:
		_initialize_nodes()

func _initialize_nodes():
	XROrigin = get_node_or_null(XROriginPath) as XROrigin3D
	XRCamera = get_node_or_null(XRCameraPath) as XRCamera3D

	if not XROrigin or not XRCamera:
		print("Initialization failed: XROrigin or XRCamera is null")
	else:
		print("Initialization successful:", XROrigin, XRCamera)

func physics_movement(delta: float, player_body: XRToolsPlayerBody, disabled: bool):
	# Disable flying if requested, or if no controller
	if disabled or !_controller or !enabled or !_controller.get_is_active():
		stop_flying()
		return

	var flight_button_pressed = _controller.is_button_pressed(flight_button)

	#  toggle
	if toggle:
		toggle_flight(flight_button_pressed)
	else:
		hold_flight(flight_button_pressed)
	
	_flight_button = flight_button_pressed

	## Process flying
	if is_flying:
		handle_flying(delta, player_body)

func toggle_flight(flight_button_pressed):
	if flight_button_pressed and !_flight_button:
		if is_flying:
			stop_flying()
		else:
			start_flying()

func hold_flight(flight_button_pressed):
	if flight_button_pressed and !is_flying:
		start_flying()
	elif !flight_button_pressed and is_flying:
		stop_flying()

# Add support for is_xr_class on XRTools classes
func is_xr_class(name : String) -> bool:
	return name == "XRToolsMovementProvider"


func start_flying():
	is_flying = true
	reference_position = get_hmd_position()
	emit_signal("flight_started")

func stop_flying():
	is_flying = false
	
	current_velocity = Vector3.ZERO
	emit_signal("flight_finished")

func handle_flying(delta: float, player_body: XRToolsPlayerBody):
	var current_pos = get_hmd_position()
	
	var direction = reference_position.direction_to(current_pos)

	var velocity_scaling = direction * flying_speed
	var resistance = current_velocity * air_resistance
	
	var lift = Vector3(current_velocity.x, abs(current_velocity.y), current_velocity.z).length()
	var lift_force =  lift * 0.05  
	
	#get direction of velocity
	#if vectors are unalike
	#double the velocity scaling ie brake faster
	
	#var vel_dir = current_velocity.normalized()
	#var scale_dir = velocity_scaling.normalized()
	#var dotprod = velocity_scaling.dot(scale_dir)
	#if dotprod < 0:
		#velocity_scaling * 2
	
	
	current_velocity += (velocity_scaling - resistance) * delta
	current_velocity.y += lift_force * delta 
	current_velocity = current_velocity.limit_length(max_speed)
	
	player_body.velocity = player_body.move_body(current_velocity)

	#print("velocity",current_velocity)
	#print("direction", direction)

func get_hmd_position() -> Vector3:
	return XRCamera.global_transform.origin - XROrigin.global_transform.origin

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = super()
	if !_camera:
		warnings.append("Unable to find XRCamera3D")
	if !_left_controller:
		warnings.append("Unable to find left XRController3D node")
	if !_right_controller:
		warnings.append("Unable to find right XRController3D node")
	return warnings
