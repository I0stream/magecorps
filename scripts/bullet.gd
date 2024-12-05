extends Area3D  # Or RigidBody3D if you need physical collisions

@export var damage: int = 20  # Damage dealt by the bullet
@export var speed: float = 500.0  # Initial speed
@export var lifetime: float = 5.0  # Time before the bullet is removed

var velocity: Vector3 = Vector3.ZERO
var elapsed_time: float = 0.0



func _ready():
	# Start a timer to destroy the bullet after its lifetime
	
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float):
	# Update position based on velocity
	velocity.y += gravity * delta  # Apply gravity
	global_transform.origin += velocity * delta

	# Check for collisions (if using Area3D)
	var space_state = get_world_3d().direct_space_state
	var physics_ray_params = PhysicsRayQueryParameters3D.create(global_transform.origin, global_transform.origin + velocity * delta)
	var collision = space_state.intersect_ray(physics_ray_params)
