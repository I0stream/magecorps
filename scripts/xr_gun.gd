@tool
class_name GunPickable
extends XRToolsPickable

@export var damage_amount = 20
@onready var shoulder_rest := $ShoulderRest
@onready var raycast := $RayCast3D

@export var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")  
@onready var bullet_spawn_point: Marker3D = $BulletSpawnPoint

# Called every frame to handle updates
func _physics_process(delta: float):
	# If the gun is being held with two hands, handle pivoting
	if _grab_driver and _grab_driver.secondary:
		handle_two_hand_pivot()

# Handle the two-hand pivot functionality
func handle_two_hand_pivot():
	if not _grab_driver or not _grab_driver.secondary:
		return

	# Get positions of the primary and secondary hands
	var primary_position = _grab_driver.primary.by.global_transform.origin
	var secondary_position = _grab_driver.secondary.by.global_transform.origin
	var pivot_position = shoulder_rest.global_transform.origin

	# Calculate the new direction
	var direction = (primary_position + secondary_position) * 0.5 - pivot_position
	direction = direction.normalized()

	# Create a Basis using the look_at method
	var new_basis = Basis()
	new_basis = new_basis.looking_at(-direction, Vector3.UP)

	# Update the gun's global transform
	global_transform = Transform3D(new_basis, pivot_position)

# Implement the shooting function
func shoot():
	if not raycast:
		return

	# Enable and update the raycast
	raycast.enabled = true
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider:
			var health = collider.get_tree().get_node("health")
			if health.has_method("take_damage"): 
				health.take_damage(damage_amount)  # Apply 20 damage (adjust as needed)
				print("Hit target: %s. Dealt 20 damage." % health.name)
		else:
			print("Hit object: %s, but it cannot take damage." % collider.name)
	else:
		print("No hit detected.")

	raycast.enabled = false



func shoot_bullet():
	if not bullet_scene:
		print("No bullet scene assigned.")
		return

	# Instance the bullet
	var bullet = bullet_scene.instantiate() as Area3D
	bullet.global_transform = bullet_spawn_point.global_transform  # Start at the player's position
	bullet.velocity = -global_transform.basis.z * bullet.speed  # Shoot forward (adjust as needed)
	get_parent().add_child(bullet)

# Extend the base action functionality
func action():
	super.action()  # Call the parent class's action function
	shoot_bullet()
