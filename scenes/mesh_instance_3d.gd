extends MeshInstance3D
@export var flash_duration: float = 0.2  # Duration of the flash in seconds
@onready var white = preload("res://materials/target_white.tres")
@onready var red = preload("res://materials/target_red.tres")
func _ready():
	$"../health".connect("damage_anim", _flash_material)
# Flash material
func _flash_material():
	$".".set_surface_override_material(red)
	await get_tree().create_timer(flash_duration).timeout  # Wait for flash duration
	$".".set_surface_override_material(white)
