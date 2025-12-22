extends Area3D
@onready var player = $"../../player"
@onready var ui = player.get_node("head/FirstPersonCamera3D/UI")

func _on_body_entered(body):
	if body is CharacterBody3D:
		ui.lose_hp(100)

func respawn():
	player.global_transform.origin = Vector3(0,0,0)
	ui.set_hp(100)
