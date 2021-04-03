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
var damage = 1 #placeholder parameter/ value
#	Non-Diagetic Parameters
var ap
var max_action_points
var apReplenishFactor
var actions_dict = [
	{"event": "attack", "cost": 4},
	{"event": "move", "cost": 1}
]
#	Pure Technical Paramenters
var entity_spawn_id
var turn_action_queue = []

onready var administrator = get_node("/root/Main") #this may change if I end up using a container for entities in the tree
onready var tween = get_node("Tween")
onready var spr = get_node("Sprite")
onready var txtAnchor = get_node("TextPopUpAnchor")

func _ready():
	rng.randomize()

	apReplenishFactor = 2

	name = "Inimigo#" + String(entity_spawn_id)
	initiative = rng.randi_range(2, 5)
	speed = rng.randi_range(2, 5)
	max_action_points = initiative + speed #min 4 - max 10
	ap = max_action_points

func run_turn():
	# this code replenishes the AP of an entity at the beginning of the turn if this entity has lost AP
	if not ap == max_action_points:
		turn_action_queue.append(["modify_AP", apReplenishFactor])
		modify_AP(apReplenishFactor) #this needs to be realocated to an action function with its own animation
	
	brain.plan_turn(actions_dict, ap)
	take_action()
	call_next_turn()

#	UNDER DEVELOPMENT
func _take_action():
	for action in turn_action_queue:
		match action:
			"modify_AP":
				call(action[0], action[1])
			"consume_AP":
				call(action[0], action[1])
#	/////////////////

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

func attack():
	#in the future maybe add the possibility to attack non-player characters
	print(name + " attacked player")
	for action in actions_dict:
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