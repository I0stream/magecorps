extends Node3D

enum PlayerState {
	MOVEMENT,
	FLIGHT,
}

@export var current_state: PlayerState = PlayerState.MOVEMENT
@onready var flight_node: XRToolsMovementFlight = $"../XROrigin3D/XRController3D_left/MovementFlight"
@onready var movement_node: XRToolsMovementDirect = $"../XROrigin3D/XRController3D_left/MovementDirect"
@onready var sound_player: AudioStreamPlayer3D = $"../SoundPlayer" 

#FX
@export var flying_trail_scene: PackedScene = preload("res://scenes/FX/flying_trail.tscn")
var flying_trail_instance: Node3D = null


func _ready():
	# Connect flight signals

	# Set initial state
	change_state(PlayerState.MOVEMENT)

func _process(delta):
	# Manage state behavior in process
	match current_state:
		PlayerState.MOVEMENT:
			handle_movement(delta)
		PlayerState.FLIGHT:
			handle_flight(delta)
			

func change_state(new_state: PlayerState):
	if current_state == new_state:
		return  # No state change

	current_state = new_state
	print("State changed to:", new_state)

	# Handle state-specific setup
	match current_state:
		PlayerState.MOVEMENT:
			on_enter_movement()
		PlayerState.FLIGHT:
			on_enter_flight()

# Handlers for movement state
func on_enter_movement():
	#print("Entering Movement State")
	if flying_trail_instance and is_instance_valid(flying_trail_instance):
		flying_trail_instance.queue_free()  # Destroy the instance
		flying_trail_instance = null
		
	#play_sound("res://sounds/movement_placeholder.wav")
	#play_animation("movement_start")

func handle_movement(delta):
	# Handle movement logic here
	pass

# Handlers for flight state
func on_enter_flight():
	#print("Entering Flight State")
	flying_trail_instance = flying_trail_scene.instantiate()
	flying_trail_instance.global_transform = global_transform  # Match player's position
	add_child(flying_trail_instance)  # Add to the player's node

func handle_flight(delta):
	# Handle flight logic here
	pass

# Signal handlers for flight node
func _on_movement_flight_flight_started():
	#print("Flight Started")
	change_state(PlayerState.FLIGHT)

func _on_movement_flight_flight_finished():
	#print("Flight Finished")
	change_state(PlayerState.MOVEMENT)

# Utility methods for effects
func play_sound(sound_stream: AudioStream):
	if sound_player:
		sound_player.stream = sound_stream
		sound_player.play()

#func play_animation(animation_name: String):
	#if animation_player and animation_player.has_animation(animation_name):
		#animation_player.play(animation_name)
