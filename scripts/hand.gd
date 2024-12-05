extends XRController3D

@export var grab_action: String = "grab_action"  # The action name to check for grab

var held_object: Node3D = null  # Reference to the currently held object
var object_old_parent: Node3D = null

func _ready():
	# Connect the built-in button_pressed and button_released signals
	connect("button_pressed", Callable(self, "_on_button_pressed"))
	connect("button_released", Callable(self, "_on_button_released"))


# Handle button pressed signal, check if it's the grab action
func _on_button_pressed(name: String):
	if name == grab_action:
		try_grab()

# Handle button released signal, check if it's the grab action
func _on_button_released(name: String):
	if name == grab_action:
		release_object()


#not working
# Attempts to grab an object
#TODO
#get transforms of rigid body
#cut out parent rigid body
#delete, queue free
#create node3d
#apply transforms to node3d
#reparent to node3d
#parent to hand


func try_grab():
	var bodies = get_node('Area3D').get_overlapping_bodies()
	if bodies:
		#check for group grabbable
		for body in bodies:
			if body.is_in_group("grabbable") and body is RigidBody3D:
				held_object = rigidbody_with_node3d(body)
				object_old_parent = body.get_parent()
				held_object.reparent(self,true)
			elif body.is_in_group("grabbable") and body is Node3D:
				held_object = body
				object_old_parent = body.get_parent().object_old_parent
				held_object.reparent(self,true)


#get transforms of node3d
#cut off parent node3d
#delete, queue free
#create new rigid body
#apply transforms
#parent to it and parent to grandparent
# Releases the held object
func release_object():
	if held_object and held_object is Node3D:
		held_object = node3D_to_rigidBody3D(held_object)
		held_object.reparent(object_old_parent)
		held_object = null




func rigidbody_with_node3d(rigid_body: RigidBody3D) -> Node3D:
	if not rigid_body:
		return

	var new_node = Node3D.new()
	new_node.name = rigid_body.name
	
	new_node.global_transform = rigid_body.global_transform
	
	for child in rigid_body.get_children():
		child.get_parent().remove_child(child)
		new_node.add_child(child)
		child.owner = new_node  # Ensure it stays in the scene tree
	
	var parent = rigid_body.get_parent()
	parent.add_child(new_node)
	new_node.owner = rigid_body.owner  # Retain scene ownership
	new_node.add_to_group("grabbable")

	rigid_body.queue_free()
	return new_node

func node3D_to_rigidBody3D(node3d: Node3D) -> RigidBody3D:
	if not node3d:
		return
	
	var new_rigid = RigidBody3D.new()
	new_rigid.name = node3d.name
	
	new_rigid.global_transform = node3d.global_transform
	
	for child in node3d.get_children():
		child.get_parent().remove_child(child)
		new_rigid.add_child(child)
		child.owner = new_rigid  # Ensure it stays in the scene tree

	var parent = node3d.get_parent()
	parent.add_child(new_rigid)
	new_rigid.owner = node3d.owner  # Retain scene ownership
	new_rigid.add_to_group("grabbable")

	node3d.queue_free()
	return new_rigid
