extends MeshInstance3D
@export var flash_duration: float = 0.2  # Duration of the flash in seconds

func _ready():
	$"../health".connect("damage_anim", _flash_material)
# Flash material
func _flash_material():
	if  material_override:
		var material = material_override as ShaderMaterial
		if material:
			material.set_shader_parameter("flash_intensity", 1.0)  # Turn on the flash
			await get_tree().create_timer(flash_duration).timeout  # Wait for flash duration
			material.set_shader_parameter("flash_intensity", 0.0)  # Turn off the flash
