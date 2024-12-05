extends Node3D

func _ready():
	# Connect the Area3D's body_entered signal to this script
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.area_entered.connect(_on_area_3d_area_entered)

func _on_body_entered(body: Node) -> void:
	pass

func _on_area_3d_area_entered(area):
	GameController.update_score()
	queue_free()
