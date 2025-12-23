extends RigidBody3D

var health = 100

#Declare Nodes
@onready var dummy_hit_sound = $Dummy_Hit_Sound

func damage_taken(damage):
	health -= damage
	dummy_hit_sound.playing = true
