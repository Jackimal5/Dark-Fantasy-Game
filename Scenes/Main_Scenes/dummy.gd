extends CharacterBody3D

var health = 100
var knockback = false
var player_position = Vector3.ZERO
var knockback_timer = 0
var knockback_multiplier = 40
var lerp_speed = 0.2

#Declare Nodes
@onready var dummy_hit_sound = $Dummy_Hit_Sound
@onready var player = $"../player"

func _physics_process(delta):
	if knockback and knockback_timer > 0:
		velocity.z = (self.position.z - player_position.z) * knockback_multiplier
		velocity.x = (self.position.x - player_position.x) * knockback_multiplier
		knockback_timer -= delta 
	else: 
		velocity.x = lerp(velocity.x, 0.0, lerp_speed)
		velocity.z = lerp(velocity.z, 0.0, lerp_speed)
	#velocity = lerp(velocity, Vector3.ZERO, lerp_speed)
	
	move_and_slide()

func damage_taken(damage, player_pos_currently):
	health -= damage
	dummy_hit_sound.playing = true
	player_position = player_pos_currently
	knockback = true
	knockback_timer = 0.01
