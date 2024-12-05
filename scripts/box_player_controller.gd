extends CharacterBody3D

# Movement speed and acceleration
@export var speed: float = 40.0
@export var acceleration: float = 5.0


@export var mouse_sensitivity: float = 0.01
var mouse_position = Vector2(0.0, 0.0)
var total_pitch = 0.0

# Input vector for movement
var input_vector: Vector3 = Vector3.ZERO
@onready var camera = $Camera3D

func _process(delta: float):
	handle_input()
	move(delta)

func handle_input():
	input_vector = Vector3.ZERO

	if Input.is_key_pressed(KEY_W):
		input_vector.z -= 1
	if Input.is_key_pressed(KEY_S):
		input_vector.z += 1

	# Left/Right movement (A/D)
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1

	# Up/Down movement (Space/Shift)
	if Input.is_key_pressed(KEY_Q):
		input_vector.y += 1
	if Input.is_key_pressed(KEY_E):
		input_vector.y -= 1

	# Normalize the input vector to prevent faster diagonal movement
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
	# Adjust movement to be relative to the camera
	var camera_basis = camera.global_transform.basis
	var forward = camera_basis.z
	var right = camera_basis.x
	var temp = (forward * input_vector.z + right * input_vector.x).normalized()
	input_vector = Vector3(temp.x, input_vector.y, temp.z)

func move(delta: float):
	# Smooth velocity change with acceleration
	velocity = velocity.lerp(input_vector * speed, acceleration * delta)

	# Apply movement
	move_and_slide()

	# Handle rotation with mouse or custom input
	handle_mouse_rotation(delta)

func handle_mouse_rotation(delta: float):
	var mouse_delta = Input.get_last_mouse_velocity() * mouse_sensitivity

	# Rotate around the Y-axis for horizontal mouse movement
	rotate_y(-mouse_delta.x * delta)

	# Calculate vertical pitch (up and down)
	var new_pitch = clamp(camera.rotation_degrees.x - mouse_delta.y * delta, -90, 90)
	camera.rotation_degrees.x = new_pitch
