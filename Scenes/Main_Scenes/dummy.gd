extends RigidBody3D

var health = 100

#Declare Nodes
@onready var dummy_hit_particles = $Dummy_Hit_Particles

func damage_taken(damage):
	health -= damage
	dummy_hit_particles.emitting = true
