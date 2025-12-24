extends CharacterBody3D

var health = 100

#Declare Nodes
@onready var dummy_hit_sound = $Dummy_Hit_Sound
@onready var player = $"../player"

func damage_taken(damage, player_postition):
	health -= damage
	dummy_hit_sound.playing = true
	
	
