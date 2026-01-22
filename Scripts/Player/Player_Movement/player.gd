extends CharacterBody3D

#Connecected Nodes:
#Head
@onready var head = $head

#Colliders
@onready var standing_collision_shape = $Standing_Collision_Shape
@onready var crouching_collision_shape = $Crouching_Collision_Shape

#RayCasts
@onready var ray_cast = $RayCast
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left_bottum = $RayCastLeftBottum
@onready var ray_cast_right_bottum = $RayCastRightBottum
@onready var ray_cast_interactions = $head/FirstPersonCamera3D/RayCastInteractions
@onready var ray_cast_attack = $head/FirstPersonCamera3D/RayCastAttack

#Sounds
@onready var your_footsteps = $"Your footsteps"

#Camera and UI
@onready var first_person_camera_3d = $head/FirstPersonCamera3D
@onready var ui = $head/FirstPersonCamera3D/UI

#Variable for Moving
var constant_speed = 0
var direction = Vector3.ZERO

#Sounds
#Adjust for faster/slower footsteps
var footstep_timer = 0.0
@export var footstep_interval_walking = 0.4
@export var footstep_interval_sprinting = 0.2
@export var footstep_interval_crouching = 0.6

#Walking
@export var walk_speed = 5.0

#Sprinting
@export var sprinting_speed = 8.0

#Jumping and Falling
@export var jump_velocity = 5
@export var wall_jumping_time = 0.38
@export var gravity = 9.8
@export var friction = 0.8
@export var running_stop_time = 0.2

#Crouching
@export var crouching_depth = 0.5
@export var crouching_speed = 3.0

#Smoothness and Mouse Sensitivity
@export var mouse_sens = 0.2
@export var lerp_speed = 10.0

#Identity
var identity = "Player"

#Blast Jump stuff
var soul_blast_jumping = false
var soul_blast_timer = 0.0
@export var soul_blast_timer_max = 1.0
@export var soul_blast_soul_loss_amp = 13.0
@export var soul_blast_jump_velocity = 5
@export var soul_blast_jump_velocity_intial = 7

#Soul quick dash stuff
var soul_quick_dash = false
@export var soul_quick_dash_amp = 40

#Types of movement
var walking = false
var sprinting = false
var crouching = false
var wall_running = false
var wall_touching = false
var wall_jumping_timer = wall_jumping_time
var wall_jumping = false
var set_camera = 1
var the_slope = 0
var input_dir = Input.get_vector("left", "right", "forward", "backward")

#Moveset
@export var moveset = {
	"soul_blast_jump" : true,
	"soul_quick_dash" : true
}

#Used to Capture Mouse
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#Used for turning your head
func _input(event):
	head_rotation(event)

#Game Loop
func _physics_process(delta):
	#Declaring input_dir
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	gravity = 9.8
	
	#Used to Uncapture my mouse so I can easily close the project
	free_mouse()
	#Wall Running
	check_wall_touching()
	wall_run()
	#Sound Effects
	sound()
	#Set Camera
	camera_set()
	#Crouching and Standing Logic 
	crouch_stand_logic(delta)
	#Checks if the player is attacking and attacks if so
	is_attacking()
	#If sprinting or walking
	is_sprinting_or_walking()
	#If not moving
	is_not_moving()
	#Adding Gravity
	gravity_pull(delta)
	#Handles movement on X and Z
	move(delta)
	#Checks for soul blast jump
	#is_blast_jump(delta)
	#Checks for quick dash
	#is_soul_quick_dash()
	#Handles jumping
	is_jumping()
	#Checks if your wall jumping or not to determine stuff 
	is_wall_jump(delta)
	#Makes all things move
	move_and_slide()

#Crouch and Stand Logic
func crouch_stand_logic(delta):
	if Input.is_action_pressed("crouch") and is_on_floor():
		#Crouch script
		crouch(delta)
	#If you aren't pressing crouch and are able to stand up
	elif !ray_cast.is_colliding() and is_on_floor():
		#Standing Script
		stand(delta)

#Rotates Head
func head_rotation(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(event.relative.x * mouse_sens * -1))
		head.rotate_x(deg_to_rad(event.relative.y * mouse_sens * -1))
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

#Deacceleration 
func is_not_moving():
	if !moving():
		sprinting = false
		walking = false
		crouching = false

#Crouch Logic
func crouch(delta):
	#Speed is set to crouching speed
	constant_speed = crouching_speed
	#Change Head Position
	head.position.y = lerp(head.position.y, 1.8 - crouching_depth, delta * lerp_speed)
	#Use Crouch hitbox
	standing_collision_shape.disabled = true
	crouching_collision_shape.disabled = false
	#States
	sprinting = false
	crouching = true

#Checks if their sprinting or walking
func is_sprinting_or_walking():
	if is_on_floor():
		if Input.is_action_pressed("sprint") and !crouching and moving() || wall_running:
				#Speed is set to sprinting speed
				constant_speed = sprinting_speed
				sprinting = true
		elif moving() and !crouching:
			#Speed is set to walking speed
			constant_speed = walk_speed
			walking = true

#Applies Gravity
func gravity_pull(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

#Checks if jumping
func is_jumping():
	if (Input.is_action_just_pressed("jump") and (is_on_floor() || wall_running)):
		#Accelerate forward
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
		elif wall_running:
			start_wall_jump()

#Blast Jump
func is_blast_jump(delta):
	if is_on_floor():
		soul_blast_timer = soul_blast_timer_max
	if moveset["soul_blast_jump"] == true:
		if Input.is_action_just_pressed("Soul Blast Jump"):
			if soul_enough(4):
				soul_blast_jumping = true
		elif Input.is_action_pressed("Soul Blast Jump"):
			if soul_enough(delta * soul_blast_soul_loss_amp):
				soul_blast_jumping = true
		else:
			soul_blast_jumping = false
		if soul_blast_jumping and soul_blast_timer <= 0:
			soul_blast_jumping = false
		if soul_blast_jumping and Input.is_action_just_pressed("Soul Blast Jump"):
			velocity.y = soul_blast_jump_velocity_intial
			soul_blast_timer -= delta
			ui.sl -= 4
		elif soul_blast_jumping and Input.is_action_pressed("Soul Blast Jump"):
			velocity.y = soul_blast_jump_velocity
			soul_blast_timer -= delta
			ui.sl -= delta * soul_blast_soul_loss_amp

#Soul Quick Dash
func is_soul_quick_dash():
	soul_quick_dash = false
	if moveset["soul_quick_dash"] == true:
		if Input.is_action_just_pressed("Soul Quick Dash") and input_dir != Vector2.ZERO:
			if soul_enough(23):
				ui.sl -= 23
				soul_quick_dash = true

#Code for wall jumping
func start_wall_jump():
	wall_jumping = true
	velocity = get_wall_normal() * 14
	velocity.y = jump_velocity * 1.6
	wall_jumping_timer = wall_jumping_time

#Check if you have enough soul to perform a certain action
func soul_enough(amount):
#	if ui.sl - amount < 0:
#		return false
#	else:
#		return true
	return

#Checks if wall jump
func is_wall_jump(delta):
	if wall_jumping:
		velocity.x *= 0.9
		velocity.z *= 0.9
		wall_jump_timer(delta)
	else:
		velocity.x *= friction
		velocity.z *= friction

func move(delta):
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta * lerp_speed)
	if direction != Vector3.ZERO and !wall_jumping and !soul_quick_dash:
		velocity.x = direction.x * constant_speed
		velocity.z = direction.z * constant_speed
	elif direction != Vector3.ZERO and !wall_jumping and soul_quick_dash:
		velocity.x = direction.x * constant_speed * soul_quick_dash_amp
		velocity.z = direction.z * constant_speed * soul_quick_dash_amp

#Checks if using Esc to free the mouse
func free_mouse():
	if Input.is_action_pressed("free_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func wall_run():
	wall_running = false
	if Input.is_action_pressed("forward") and Input.is_action_pressed("sprint") and is_on_wall() and wall_touching and sprinting:
		wall_running = true
		velocity.y *= friction

func wall_jump_timer(delta):
	wall_jumping_timer -= delta
	if wall_jumping_timer <= 0:
		wall_jumping = false
		
	elif (velocity.z >= 0 and velocity.x >= 0):
		if (velocity.z < running_stop_time and velocity.x < running_stop_time):
			wall_jumping = false
			
	elif (velocity.z <= 0 and velocity.x <= 0):
		if (velocity.z > -running_stop_time and velocity.x > -running_stop_time):
			wall_jumping = false

func sound():
	if (walking || sprinting || crouching) and is_on_floor() || wall_running:
		footstep_timer -= get_physics_process_delta_time()
		if footstep_timer <= 0:
			if sprinting:
				footstep_timer = footstep_interval_sprinting
			elif crouching:
				footstep_timer = footstep_interval_crouching
			elif walking:
				footstep_timer = footstep_interval_walking
			your_footsteps.moving()
	else:
		footstep_timer = 0.0

func camera_set():
	if set_camera == 1:
		first_person_camera_3d.current = true

func check_wall_touching():
	if ray_cast_left.is_colliding() || ray_cast_right.is_colliding() || ray_cast_left_bottum.is_colliding() || ray_cast_right_bottum.is_colliding():
		wall_touching = true
	else:
		wall_touching = false

#Checks if player is moving
func moving():
	if Input.is_action_pressed("forward") || Input.is_action_pressed("backward") || Input.is_action_pressed("left") || Input.is_action_pressed("right"):
		return true
	else: 
		return false

#Makes the player stand
func stand(delta):
	crouching = false
	standing_collision_shape.disabled = false 
	crouching_collision_shape.disabled = true
	#Change Head Position
	head.position.y = lerp(head.position.y, 1.8, delta * lerp_speed)

#Checks if attacking
func is_attacking():
	if Input.is_action_just_pressed("attack") and ray_cast_attack.is_colliding():
		ray_cast_attack.get_collider().damage_taken(12, global_position)
