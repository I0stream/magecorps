extends Node

var score: int = 0
@export var score_limit: int = 13 #13 on island

@export var xr_player_scene: PackedScene = preload("res://scenes/VR/xr_tools_player_controller.tscn")
@export var box_player_scene: PackedScene = preload("res://scenes/box_player_controller.tscn")
@onready var spawn_point: Node3D = $spawn_point


func _ready() -> void:
	GameController.connect("playerWon",Callable(self, "_on_player_win"))
	if not spawn_point:
		printerr("Spawn point not found in the scene!")
		return

	if is_xr_available():
		spawn_controller(xr_player_scene)
		print("XR environment detected: Spawning XR Player Controller at spawn point.")
	else:
		spawn_controller(box_player_scene)
		print("No XR environment detected: Spawning Box Player Controller at spawn point.")

func _on_player_win():
	print("you won!")



func is_xr_available() -> bool:
	# Check if an XR runtime is available and initialized
	var xr_interface = XRServer.find_interface("OpenXR")
	xr_interface.initialize()
	if xr_interface.is_initialized():
		return true
	else:
		return false

func spawn_controller(controller_scene: PackedScene):
	var controller_instance = controller_scene.instantiate()
	add_child(controller_instance)

	# Position the controller at the spawn point's location
	controller_instance.global_transform = spawn_point.global_transform
