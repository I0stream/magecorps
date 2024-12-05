extends CharacterBody3D

@onready var left_hand: XRController3D = $XROrigin3D/left
@onready var right_hand: XRController3D = $XROrigin3D/right


@export var flying_speed = 10
@export var air_resistance = 0.05
@export var max_speed = 50
@export var gravity = -9.8
@export var move_speed = 1.5
@export var turn_angle = 30.0
@export var mass = 80 #kg
@export var joystick_deadzone = 0.0
@export var ground_friction = 9.0

@export var level: Node = null  # Optional reference to the Level node
var floating_ui: Node3D = null

var reference_position = Vector3.ZERO
var is_flying = false
var current_velocity = Vector3.ZERO
var held_object_left: Node3D = null
var held_object_right: Node3D = null
var turn_speed := 2.0 # Controls the speed of the turn, adjust as needed
var target_rotation := 0.0
var current_rotation := 0.0

var spell_action: String = "spell_action"

func _ready():
	
	get_viewport().use_xr = true
	var xr_interface = XRServer.find_interface("OpenXR")
	
	if xr_interface:
		xr_interface.initialize()
	else:
		print("OpenXR interface not found.")
	
	
	$textify.received.connect(_spell_compare)
	left_hand.connect("button_pressed", Callable(self, "_on_button_pressed"))
	left_hand.connect("button_released", Callable(self, "_on_button_released"))



func _process(delta):

	if left_hand.is_button_pressed("fly_action"):
		start_flying()

	# Right hand
	if right_hand.is_button_pressed("shoot_action") and is_holding_weapon():
		shoot_weapon()

	if right_hand.is_button_pressed("input_action"):
		handle_input_action()

	if right_hand.is_button_pressed("cancel_action"):
		cancel_action()

	# Movement with right hand joystick
	var move_vector = left_hand.get_vector2("move_action")
	if move_vector.length() > 0:
		handle_ground_movement(delta)

	# Snap turn with left hand joystick
	var turn_value = right_hand.get_vector2("turn_action")
	if turn_value.length() > joystick_deadzone:
		handle_snap_turn(turn_value, delta)

@warning_ignore("shadowed_variable_base_class")
func _on_button_pressed(name: String):
	if name == spell_action:
		record_audio()

@warning_ignore("shadowed_variable_base_class")
func _on_button_released(name: String):
	if name == spell_action:
		end_recording()

#spell choice
func _spell_compare(text):

	var result = Spells.fuzzy_match_spell(text)
	match result:
		Spells.Spell.FIREBOLT:
			print("Matched spell: FIREBOLT")
		Spells.Spell.HEAL:
			print("Matched spell: HEAL")
		Spells.Spell.MAGIC_MISSILE:
			print("Matched spell: MAGIC MISSILE")
		-1:
			print("Unknown spell!")


func record_audio():
	$textify.start_recording()

func end_recording():
	$textify.stop_recording()

func _on_win() -> void:
	@warning_ignore("standalone_expression")
	$XROrigin3D/WinUI.show

func _position_floating_ui() -> void:
	# Position the UI in front of the player
	@warning_ignore("shadowed_variable_base_class")
	var transform = self.global_transform
	var forward = -transform.basis.z  # Forward vector
	floating_ui.global_transform.origin = transform.origin + forward * 2.0  # 2 meters in front
	floating_ui.look_at(transform.origin, Vector3.UP)  # Make it face the player

func _physics_process(delta):
	if is_flying:
		handle_flying(delta)
	else:
		handle_ground_movement(delta)


# Left hand button pressed and released handlers
# Left hand grab/release handlers

func try_grab(controller: XRController3D):
	var area = controller.get_node("Area3D")
	
	if not area:
		print("Error: Area3D node not found in controller.")
		return

	var overlapping_bodies = area.get_overlapping_bodies()
	
	if overlapping_bodies.size() > 0:
		var grabbed_object = overlapping_bodies[0]
		
		if grabbed_object.has_method("grab"):
			grabbed_object.grab()
			controller.add_child(grabbed_object)
			grabbed_object.global_transform = controller.global_transform
			
			if controller == left_hand:
				held_object_left = grabbed_object
			elif controller == right_hand:
				held_object_right = grabbed_object
			
			print("Grabbed object:", grabbed_object)
		else:
			print("Object does not have a 'grab' method.")
	else:
		print("No objects to grab in reach.")

func release_object(controller: XRController3D):
	if controller == left_hand and held_object_left:
		held_object_left.release()
		get_parent().add_child(held_object_left)
		held_object_left = null
		print("Released object from left hand.")
	elif controller == right_hand and held_object_right:
		held_object_right.release()
		get_parent().add_child(held_object_right)
		held_object_right = null
		print("Released object from right hand.")

func is_holding_weapon() -> bool:
	# Placeholder for weapon holding logic
	return held_object_right != null

func shoot_weapon():
	if right_hand.get_held_object().is_in_group("weapons"):
		print("Shooting weapon")
	elif left_hand.get_held_object().is_in_group("weapons"):
		print("Shooting weapon")

func handle_smooth_turn(turn_value: Vector2, delta: float):
	if turn_value.x != 0:
		target_rotation += deg_to_rad(-turn_value.x * turn_speed)

	current_rotation = lerp(current_rotation, target_rotation, 5 * delta)
	rotate_y(current_rotation * delta)

func handle_snap_turn(turn_value: Vector2, delta:float):
	rotate_y(-1 * turn_value.x * delta )

func start_flying():
	is_flying = true
	reference_position = get_hmd_position()

func handle_flying(delta):
	var current_pos = get_hmd_position()
	print(get_hmd_position())
	
	var direction = reference_position.direction_to(current_pos)
	var force = direction * flying_speed
	var resistance = current_velocity * air_resistance
	current_velocity += (force - resistance ) * delta
	current_velocity = current_velocity.limit_length(max_speed)
	global_translate(current_velocity * delta)



func handle_ground_movement(delta):
	var input_vector = left_hand.get_vector2("move_action")  # Assuming "move_action" is defined in OpenXR settings
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Reset vertical velocity if on the ground
		velocity.y = 0
		
	if input_vector.length() > joystick_deadzone:
		# Normalize and scale the input vector by move speed
		input_vector = input_vector.normalized() * move_speed

		# Calculate the direction of movement based on camera orientation
		var forward = -$XROrigin3D/XRCamera3D.global_transform.basis.z.normalized()
		var right = $XROrigin3D/XRCamera3D.global_transform.basis.x.normalized()
		var movement = (forward * input_vector.y) + (right * input_vector.x)

		# Set the velocity for movement, ensuring it's in the correct direction
		velocity.x = movement.x
		velocity.z = movement.z
	else:
		velocity.x = lerp(velocity.x, 0.0, ground_friction * delta)
		velocity.z = lerp(velocity.z, 0.0, ground_friction * delta)

	# Apply movement with collision handling
	move_and_slide()

func handle_input_action():
	print("Input action triggered")

func cancel_action():
	print("Cancel action triggered")


func get_hmd_position() -> Vector3:
	return $XROrigin3D/XRCamera3D.global_transform.origin - $XROrigin3D.global_transform.origin
