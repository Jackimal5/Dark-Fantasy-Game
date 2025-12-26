extends Area3D
@onready var player = $"../../player"
@onready var ui = player.get_node("head/FirstPersonCamera3D/UI")

#Checks if body has entered it if so checks if it's the player and then if it is the player it kills the player
func _on_body_entered(body):
	if body is CharacterBody3D and body.identity == "Player":
		ui.lose_hp(100)

#Respawns the player
func respawn():
	player.global_transform.origin = Vector3(0,0,0)
	ui.set_hp(100)
