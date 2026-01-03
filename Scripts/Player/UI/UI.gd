extends CanvasLayer

#Declaring Nodes
#UI Bar Nodes
@onready var health = $Health
@onready var soul = $Soul
#Other player nodes
@onready var player = $"../../.."
@onready var interaction = $Interaction
@onready var you_need_help = $"../../../../Stage/You need help"
@onready var interacting_npc = $Interacting_NPC
@onready var interacting_npc_text = $Interacting_NPC/Interacting_NPC_Text
#NPC Dialogue handler node
@onready var scribe = $"../../../Scribe"


#Data:
#Health Varible 
var hp = 100
var sl = 100

#Shows press "E" to interact
var able_interactions = false

#Checks for if you are currently interacting
var interacting = false

# Called every frame
func _process(_delta):
	able_to_interact_interactions()
	choice()
	interacting_check()
	interaction_ui_check()
	health_process()
	soul_process()

#Changes health 
func lose_hp(health_lost):
	hp =- health_lost
func gain_hp(health_gained):
	hp =+ health_gained
func set_hp(health_set):
	hp = health_set

#Process for Health
func health_process():
	health.value = hp
	if hp <= 0:
		hp = 0
		you_need_help.respawn()
	if hp > 100:
		hp = 100

#Process for Soul
func soul_process():
	soul.value = sl
	if sl <= 0:
		sl = 0

#Interaction display
func interaction_ui_check():
	if interacting_text() != "EXIT" and able_interactions:
		interaction.show()
	else:
		interaction.hide()
	
	if interacting_text() != "EXIT" and interacting and able_interactions:
		interacting_npc.show()
	else:
		interacting_npc.hide()

#Interacts with NPC
func interacting_check():
	if Input.is_action_just_pressed("interact"):
		if interacting_text() != "EXIT" and able_interactions == true:
			interacting_npc_text.text = interacting_text()
			interacting = true
		else: 
			interacting = false

#Checks if interacting is avaliable
func able_to_interact_interactions():
	if player.ray_cast_interactions.is_colliding() and interacting_text() != "EXIT":
		able_interactions = true
	else: 
		able_interactions = false

#The spagheti that allows you to be shown interacting text
func interacting_text():
	if able_interactions == true:
		return str(scribe.npc_dialogue(player.ray_cast_interactions.get_collider().id))

func choice():
	if interacting and input_choice() and interacting_text() != "EXIT" and able_interactions:
		if Input.is_action_just_pressed("Choice 1"):
			interacting_npc_text.text = choice_text(1)
		elif Input.is_action_just_pressed("Choice 2"):
			interacting_npc_text.text = choice_text(2)
		elif Input.is_action_just_pressed("Choice 3"):
			interacting_npc_text.text = choice_text(3)
		elif Input.is_action_just_pressed("Choice 4"):
			interacting_npc_text.text = choice_text(4)
		else:
			interacting_npc_text.text = "Error 2 choice not indicated correctly"

#The spagheti that allows you to be shown new text
func choice_text(choice_id):
	return str(scribe.npc_response((player.ray_cast_interactions.get_collider().id), choice_id))

#Checks if the input is a choice or if its not
func input_choice():
	if Input.is_action_just_pressed("Choice 1") or Input.is_action_just_pressed("Choice 2") or Input.is_action_just_pressed("Choice 3") or Input.is_action_just_pressed("Choice 4"):
		return true
	else: 
		return false

#Updates the NPC to update their ID
func update_npc_id(new_id):
	player.ray_cast_interactions.get_collider().id = new_id
