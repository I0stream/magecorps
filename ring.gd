extends Node3D

func _ready():
	# Connect the Area3D's body_entered signal to this script
	$Area3D.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	print(body)
	GameController.update_score()
	queue_free()
