extends Node3D

@export var missile_scene: PackedScene = preload("res://scenes/VR/magic_missile.tscn")
@export var fire_scene: PackedScene = preload("res://scenes/FX/fire/fire.tscn")

var direction: Vector3 = Vector3(0,0,1)
var zeroPosition: Vector3 = Vector3.ZERO

func _ready():
	WhisperGlobal.connect("whisper_recieved", _spell_compare)


func _spell_compare(text):
	var result = Spells.fuzzy_match_spell(text)
	match result:
		Spells.Spell.FIREBOLT:
			print("Matched spell: FIREBOLT")
			shoot_firebolt(zeroPosition,direction)
		Spells.Spell.HEAL:
			print("Matched spell: HEAL")
			print("not implemented")
		Spells.Spell.MAGIC_MISSILE:
			print("Matched spell: MAGIC MISSILE")
			shoot_missile(zeroPosition,direction)
		-1:
			print("Fizzle, Unknown spell!")

func shoot_missile(position: Vector3, direction: Vector3):
	var missile = missile_scene.instantiate()
	missile.global_transform.origin = position
	missile.velocity = direction.normalized() * missile.speed
	add_child(missile)
	await get_tree().create_timer(10.0).timeout
	missile.queue_free()

func shoot_firebolt(position:Vector3, direction: Vector3):
	var firebolt = fire_scene.instantiate()
	firebolt.global_transform.origin = position
	firebolt.velocity = direction.normalized() * 50
	add_child(firebolt)
	await get_tree().create_timer(5.0).timeout
	firebolt.queue_free()
	
