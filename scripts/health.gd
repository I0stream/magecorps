extends Node3D

@export var max_health: int = 100
@export var current_health: int = 100
@export var flash = false
signal damage_anim
var killed = false
# Signal emitted when health reaches zero
signal destroyed

func _ready():
	current_health = max_health

# Function to apply damage
func take_damage(amount: int):
	current_health -= amount
	print("%s's health reduced by %d. Current health: %d" % [name, amount, current_health])
	
	if flash:
		emit_signal("damage_anim")
	
	if current_health <= 0:
		die()

# Function to handle destruction
func die():
	print("%s is destroying its parent!" % name)
	killed =  true
	emit_signal("destroyed")
	if get_parent():
		get_parent().queue_free()  # Destroy the parent node
	queue_free()  # Destroy the health script itself
