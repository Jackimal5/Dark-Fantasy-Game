extends Node

var id_update_needed = false

var dialogue_data = {
	10 : "Hello \n1. Bye \n2.Do you have any quests?",
	11 : "No, but you can go hit the dummy over their \n1. Okay thanks \n2. Your stupid",
	12 : "...",
	0 : "EXIT",
}

var resulting_dialogue_data = {
	10.1: 0,
	10.2: 11,
	11.1: 0,
	11.2: 0,
}

@onready var ui = $"../head/FirstPersonCamera3D/UI"

func is_id_update_needed(id, choice, npc):
	if id_update_needed:
		return resulting_dialogue_data[id + (0.1 * choice)]
	else:
		return false

func npc_dialogue(id):
	if dialogue_data != null:
		return dialogue_data[id]
	else: 
		return "Error 1: Num not found"

func npc_response(id, choice, npc):
	if resulting_dialogue_data != null:
		ui.update_npc_id(11)
		return dialogue_data[resulting_dialogue_data[id + (0.1 * choice)]]
	else: 
		return "Error 1: Num not found"
