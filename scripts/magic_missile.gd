extends Node3D

@export var speed: float = 15.0  # Missile's movement speed
@export var turn_rate: float = 5.0  # How quickly the missile arcs toward targets
@export var lifetime: float = 10.0  # Maximum lifetime of the missile
@export var damage: int = 50  # Damage dealt to enemies
@export var target_range: float = 20.0  # Range to detect enemies

@onready var area: Area3D = $Area3D
@onready var particles: GPUParticles3D = $GPUParticles3D

var velocity: Vector3 = Vector3.ZERO
var target: Node3D = null
var time_alive: float = 0.0

func _ready():
	# Start the missile's lifetime timer
	await get_tree().create_timer(lifetime).timeout
	queue_free()  # Destroy the missile after its lifetime

func _physics_process(delta: float):
	# Find a target if none exists
	if not target:
		find_target()

	# Adjust velocity to arc toward the target
	if target and is_instance_valid(target):
		arc_toward_target(delta)

	# Move the missile
	global_transform.origin += velocity * delta

	# Update the tail effect position
	if particles:
		particles.global_transform.origin = global_transform.origin

func find_target():
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape_rid = area.shape.get_rid()  # Assign the shape's RID
	query.transform = global_transform  # Use the missile's current global transform
	query.collision_layer = 1  # Adjust to match your enemies' collision layer

	# Perform the shape query
	var results = space_state.intersect_shape(query)

	for result in results:
		if result.collider and result.collider.is_in_group("enemies"):
			target = result.collider
			break

func arc_toward_target(delta):
	var direction_to_target = (target.global_transform.origin - global_transform.origin).normalized()
	velocity = velocity.lerp(direction_to_target * speed, turn_rate * delta)  # Smoothly arc toward the target

# Handle collisions
func _on_Area3D_body_entered(body):
	if body and body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		# Destroy the missile after hitting the target
		queue_free()
