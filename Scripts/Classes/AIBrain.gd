class_name AIBrain extends Node2D

var possible_actions = []

func _ready():
	pass # Replace with function body.

func define_stance():
	pass

func decide_action(action_list, current_ap):
	for action in action_list:
		if action.cost <= current_ap:
			possible_actions.append(action)
			
	pass

#func _process(delta):
#	pass
