extends Node3D

var primary_hand: XRController3D = null
var secondary_hand: XRController3D = null
var is_grabbed_primary: bool = false
var is_grabbed_secondary: bool = false

func _ready():
	add_to_group("weapons")
	# Connect the grip areas to detect hand overlap
	$Grip1.body_entered.connect(_on_grip1_body_entered)
	$Grip1.body_exited.connect(_on_grip1_body_exited)
	$Grip2.body_entered.connect(_on_grip2_body_entered)
	$Grip2.body_exited.connect(_on_grip2_body_exited)

func _on_grip1_body_entered(body: Node):
	if body.is_in_group("hand") and primary_hand == null:
		primary_hand = body
		is_grabbed_primary = true

func _on_grip1_body_exited(body: Node):
	if body == primary_hand:
		primary_hand = null
		is_grabbed_primary = false

func _on_grip2_body_entered(body: Node):
	if body.is_in_group("hand") and secondary_hand == null:
		secondary_hand = body
		is_grabbed_secondary = true

func _on_grip2_body_exited(body: Node):
	if body == secondary_hand:
		secondary_hand = null
		is_grabbed_secondary = false

func _process(delta):
	if is_grabbed_primary and primary_hand:
		# If only primary hand is grabbing, align gun to primary hand
		if not is_grabbed_secondary:
			global_transform.origin = primary_hand.global_transform.origin
			look_at(primary_hand.global_transform.origin, Vector3.UP)
		# If both hands are grabbing, align gun between both hands with pivot at the butt
		elif is_grabbed_secondary and secondary_hand:
			var midpoint = (primary_hand.global_transform.origin + secondary_hand.global_transform.origin) / 2
			$Pivot.global_transform.origin = midpoint
			var direction = primary_hand.global_transform.origin.direction_to(secondary_hand.global_transform.origin)
			look_at(midpoint, Vector3.UP)
