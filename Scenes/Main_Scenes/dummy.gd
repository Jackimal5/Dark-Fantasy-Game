extends CharacterBody3D

@export var health = 100
var knockback = false
var player_position = Vector3.ZERO
var knockback_timer = 0
@export var knockback_multiplier = 13
@export var lerp_speed = 0.15
@export var gravity = 9.8

#Identity
var identity = "Dummy"

#Declare Nodes
@onready var dummy_hit_sound = $Dummy_Hit_Sound
@onready var player = $"../player"

func _physics_process(delta):
	if knockback and knockback_timer > 0:
		var k_velocity_x = (global_transform.origin.x - player_position.x)
		var k_velocity_z = (global_transform.origin.z - player_position.z)
		velocity = Vector3(k_velocity_x, 0.0, k_velocity_z).normalized() * knockback_multiplier
		knockback_timer -= delta 
		
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	velocity.x = lerp(velocity.x, 0.0, lerp_speed)
	velocity.z = lerp(velocity.z, 0.0, lerp_speed)
	
	move_and_slide()

func damage_taken(damage, player_pos_currently):
	health -= damage
	dummy_hit_sound.playing = true
	player_position = player_pos_currently
	knockback = true
	knockback_timer = 0.01
