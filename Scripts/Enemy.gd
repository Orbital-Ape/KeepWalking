extends Node2D


signal valueChangeNotice(obj, value, tipo)
signal passTurn
signal attackPlayer(damage)

var rng = RandomNumberGenerator.new()
var classBrain = load("res://Scripts/Classes/AIBrain.gd")
var brain = classBrain.new()

#	Meta Parameters
var initiative
var speed
var damage = 2 #placeholder parameter/ value
#	Non-Diagetic Parameters
var ap
var hp
var max_action_points
var max_health_points
var status_situation_list = [] #currently not used
var apReplenishFactor = 2 #placeholder value
var actions_list = ["melee_attack", "ranged_attack", "move_away", "move_towards", "move_defensively"]
#	Pure Technical Paramenters
var entity_spawn_id
var turn_action_queue = []

onready var administrator = get_node("/root/Main") #this may change if I end up using a container for entities in the tree
onready var tween = get_node("Tween")
onready var spr = get_node("Sprite")
onready var txtAnchor = get_node("TextPopUpAnchor")

func _ready():
	rng.randomize()

	name = "Inimigo#" + String(entity_spawn_id) #placeholder value
	initiative = rng.randi_range(2, 5) #placeholder value definition
	speed = rng.randi_range(2, 5) #placeholder value definition
	max_action_points = initiative + speed #min 4 - max 10
	ap = max_action_points

func run_turn():
	# this code replenishes the AP of an entity at the beginning of the turn if this entity has lost AP
	if not ap == max_action_points: #UPDATE 04/04/2021 - this will probably be an automatic action, not decided by the classBrain
		turn_action_queue.append(["modify_AP", apReplenishFactor])
		modify_AP(apReplenishFactor) #this needs to be realocated to an action function with its own animation
	
	analyse_condition() #current work step
	brain.define_stance()
		#what will be analysed:
			#hero condition parameter
			#self condition paramenter
				#the enemy needs to check its own condition at the beginning of the turn
			#group condition
				#I need to design a way for this to be checked
	brain.decide_action(actions_list, ap)
	take_action()
	call_next_turn()

func _take_action():
	for action in turn_action_queue:
		#all actions:
			#have a name - that is used to call the function
			#execute an animation
			#have a ap cost value
			#have a type - that is used to define its weight multiplier or to permit or deny the action
		match action:
			"modify_AP":
				call(action[0], action[1])
			"consume_AP":
				call(action[0], action[1])

func analyse_condition():
	var possible_status_conditions = [{"situation": "critical", "value": 0}, {"situation": "dangerous", "value": 2}, {"situation": "fine", "value": 4 "safe"}, {"situation": "nominal", "value": ]
	var current_ap_percentage = (ap / max_action_points) * 100
	var current_hp_percentage = (hp / max_health_points) * 100
	var status_group_percentage = [{"status_name": "ap", "percentage": current_ap_percentage, "situation": "normal", "weight": 1}, 
	{"status_name": "hp", "percentage": current_hp_percentage, "situation": "normal", "weight": 4}]
	for status in status_group_percentage:
		if status.percentage == 100:
			status.situation = "nominal"
		elif status.percentage > 80:
			status.situation = "safe"
		elif status.percentage > 60:
			status.situation = "fine"
		elif status.percentage > 40:
			status.situation = "dangerous";
		else:
			status.situation = "critical"
	
	for 		
	#is the current ap value acceptable?					- weight 1
	#is the current hp value acceptable?					- weight 4

func take_action():
	var action_cost
	if rng.randi_range(1, 2) == 1:
		action_cost = -2
	else:
		action_cost = -4
	modify_AP(action_cost)
	animate_action("modulate", Color("#f70000"), Color("#ffffff"), 0.3, tween.TRANS_BACK, tween.EASE_IN)
	print(name + " took action for " + String(action_cost) + " AP")
	print(name + " now has " + String(ap) + " action points.")

func melee_attack():
	#in the future maybe add the possibility to attack non-player characters
	print(name + " attacked player")
	for action in actions_list:
		if action.event == "attack":
			modify_AP(action.cost)
	emit_signal("attackPlayer", damage)

func modify_AP(quantity):
	var animColor
	if quantity > 0:
		animColor = GCC.apReplenished
	else:
		animColor = GCC.apConsumed
	ap = clamp(ap + quantity, 0, max_action_points)
	emit_signal("valueChangeNotice", self, quantity, "AP")
	
func call_next_turn():
	print(name + " ended its turn.")
	emit_signal("passTurn")

func _on_Tween_tween_completed(_object, _key):
	pass

func animate_action(property, starting_value, ending_value, time_duration, transition_form, ease_form):
	tween.interpolate_property($Sprite, property, starting_value, ending_value, time_duration, transition_form, ease_form)
	tween.start()