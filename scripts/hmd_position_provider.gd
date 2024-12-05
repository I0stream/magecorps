extends Node3D

# Signal for live HMD position updates
signal hmd_position_updated(position: Vector3)

# Cached HMD position (relative to XR Origin)
var hmd_position: Vector3 = Vector3.ZERO

# Method to calculate the HMD position
func get_hmd_position() -> Vector3:
	if not has_node("XROrigin3D/XRCamera3D"):
		return Vector3.ZERO

	var xr_origin = get_parent()
	var xr_camera = xr_origin.get_node("XRCamera3D")
	return xr_camera.global_transform.origin - xr_origin.global_transform.origin

# Update the HMD position each frame
func _process(delta: float):
	var new_position = get_hmd_position()
	if new_position != hmd_position:
		hmd_position = new_position
		emit_signal("hmd_position_updated", hmd_position)
