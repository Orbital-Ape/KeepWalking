class_name Entity extends Node2D

onready var main = get_node("/root/Main")

#define atributes
var condition = 100 #preset for 'first round>first turn' - checkup
var conditional_parameters = [
    {"name": "health_points", "max_value": 0, "current_value": 0, "weight": 3},
    {"name": "action_points", "max_value": 0, "current_value": 0, "weight": 1},
    {"name": "player", "player_reference": Reference, "player_position": Vector2(0, 0), "player_condition": 100, "weight": 2},
    {"name": "comrade", "comrade_reference": Reference, "comrade_position": Vector2(0, 0), "current_condition": 0, "weight": 1},
    {"name": "group", "original_size": 0, "current_size": 0, "weight": 2}
]
var atributes = [
    {"name": "initiative", "max_value": 0, "current_value": 0},
    {"name": "speed", "max_value": 0, "current_value": 0},
    {"name": "mind", "max_value": 0, "current_value": 0},
    {"name": "strength", "max_value": 0, "current_value": 0},
    {"name": "perception", "max_value": 0, "current_value": 0},
    {"name": "endurance", "max_value": 0, "current_value": 0}
]
var appearance
var status = []
var comrade_group = []

func _ready():
    for entity in main.encountered_group:
        if entity.global_position == global_position:
            continue
        conditional_parameters[3].comrade_reference = entity
        conditional_parameters[3].comrade_position = global_position
        conditional_parameters[3].current_condition = entity.condition
        comrade_group.append(conditional_parameters[2].duplicate())


func run_turn():
    animate_action(execute_action(define_action(checkup())))


func checkup():
    conditional_parameters[2].player_reference = main.get_node("Player")
    conditional_parameters[2].player_position = conditional_parameters[2].player_reference.global_position
    conditional_parameters[2].player_condition = conditional_parameters[2].player_reference.condition
    var hp = conditional_parameters[0]
    var ap = conditional_parameters[1]
    var current_ap_percentage = ap.current_value / ap.max_value * 100
    var current_hp_percentage = hp.current_value / hp.max_value * 100
    #check own condition
    if current_ap_percentage > current_hp_percentage:
        condition = current_hp_percentage + ((current_ap_percentage - current_hp_percentage) / hp.weight)
    else:
        condition = current_hp_percentage - ((current_hp_percentage - current_ap_percentage) / hp.weight)
    #check each comrade condition
    for comrade in comrade_group:
        if comrade.current_condition > condition:
            condition = condition + (((comrade.current_condition - condition) * comrade.weight) / hp.weight)
        else:
            condition = condition - (((condition - comrade.current_condition) * comrade.weight) / hp.weight)
    #check whole group condition
    # <- NEED TO DEFINE THE WAY GROUPS WILL BE SPAWNED FIRST
    #check player condition
    if conditional_parameters[2].player_condition > condition:
        condition = condition + (((conditional_parameters[2].player_condition - condition) * conditional_parameters[2].weight) / hp.weight)
    else:
        condition = condition - (((condition - conditional_parameters[2].player_condition) * conditional_parameters[2].weight) / hp.weight)

func define_action(situation):
    pass

func execute_action(action):
    pass

func animate_action(action):
    pass