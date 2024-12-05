extends Path3D

@export var scene_to_instance: PackedScene  # Scene to instance along the path
@export var num_instances: int = 10  # Number of instances to place
@export var offset: float = 0.0  # Offset for adjusting start position along the path
@onready var loadcurve = preload("res://scenes/maps/curve.tres")

func _ready():
	if not scene_to_instance:
		print("No scene assigned to instance.")
		return

	var curve = loadcurve  # Get the Curve3D from the Path3D
	var total_length = curve.get_baked_length()
	if total_length <= 0 or num_instances < 1:
		print("Invalid curve length or instance count.")
		return

	# Calculate spacing between instances
	var spacing = total_length / num_instances

	for i in range(num_instances):
		var t = i / float(num_instances - 1)  # Normalize position along the curve (0 to 1)
		var position = curve.sample_baked(t)  # Get position on the curve
		
		var tangent = curve.sample_baked(t).normalized()  # Forward direction
		var up = curve.sample_baked_up_vector(t).normalized()  # Up vector
		var side = tangent.cross(up).normalized()  # Side vector (orthogonal)

		# Construct the Basis
		var basis = Basis(tangent, up, side)

		# Instance and place the object
		var instance = scene_to_instance.instantiate()
		instance.global_transform = Transform3D(basis, position)  # Combine Basis and position
		add_child(instance)
