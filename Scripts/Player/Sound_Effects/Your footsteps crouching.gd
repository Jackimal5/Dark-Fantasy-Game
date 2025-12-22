extends AudioStreamPlayer3D

func _ready():
	crouching()
	
func crouching():
	randomize()
	randomize_pitch()
	play()

func randomize_pitch():
	var random_pitch = randf_range(0.9, 1.1) # Adjust the range as needed
	pitch_scale = random_pitch
	print("Pitch set to: ", random_pitch)
