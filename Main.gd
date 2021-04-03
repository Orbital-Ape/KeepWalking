extends Node

var sorter = TurnOrderSorter.new()
var current_round
var turn_order
var encounter_entity_list = []

onready var preloader = get_node("ResourcePreloader")

#	CLASSES
#	Sorting Class
class TurnOrderSorter:
	#	sorts based on the current entity ap
	static func sort_ap_ascending(a, b):
		if a["ap"] > b["ap"]:
			return true
		return false
	#	sorts based on the initiative
	static func sort_initiative_ascending(a, b):
		if a["initiative"] > b["initiative"]:
			return true
		return false
#	------//------//------

func _ready():
	current_round = 1

	spawn_ui()
	initiate_encounter()
	request_spawn_for_non_player_entities(2)
	request_spawn_for_player()
	rotate_to_next_round()

#	SUBROUTINES
#	Spawner Subroutine
func spawn_object(spPosition: Vector2, spObject: String, is_ui: bool, objID: int, value: int = 0, tipo: String = "nada"):
	var spawned_object
	spawned_object = preloader.get_resource(spObject).instance()
	if not is_ui:
		spawned_object.position = spPosition
		spawned_object.entity_spawn_id = objID
		$Encounter.add_child(spawned_object)
		encounter_entity_list.append(spawned_object)
	elif is_ui:
		spawned_object.rect_position = spPosition
		var mathSign
		if value > 0:
			mathSign = "+"
		elif value < 0:
			mathSign = ""
		else:
			mathSign = ""
		spawned_object.text = (mathSign + str(value) + " " + tipo)
		get_node("UI/ActionScreen").add_child(spawned_object)
	return spawned_object

func request_spawn_for_non_player_entities(times):
	var pos = get_node("Encounter/EncounterPosZero").position
	for _i in range(1, times + 1):
		var entity = spawn_object(pos, "Enemy", false, _i)
		entity.connect("passTurn", self, "_on_pass_turn")
		entity.connect("valueChangeNotice", self, "_on_value_change_notice")
		print(entity.name + " has " + String(entity.initiative) + " initiative and " + String(entity.speed) + " speed resulting in: " + String(entity.max_action_points) + " max AP.")
		pos = pos + Vector2(32, 32)

func request_spawn_for_player():
	var player = spawn_object(get_node("Encounter/EncounterPosZero/CharacterStartingPos").global_position, "Player", false, 1)
	print(player.name + " has " + String(player.initiative) + " initiative and " + String(player.speed) + " speed resulting in: " + String(player.max_action_points) + " max AP.")
#	----//----//----

func spawn_ui():
	var ui = preloader.get_resource("UI").instance()
	add_child(ui)	

#	Sorting Subroutine
func sort_current_round_turn_order():
	print("////////////////////")
	if current_round == 1:
		print("The combat has started!")
		encounter_entity_list.sort_custom(TurnOrderSorter, "sort_initiative_ascending")
	else:
		encounter_entity_list.sort_custom(TurnOrderSorter, "sort_ap_ascending")
	for ent in encounter_entity_list:
		print(ent.name + " currently has " + String(ent.ap) + " AP, of max " + String(ent.max_action_points) + " AP.")
	print("This is the next turn order:")
	print(encounter_entity_list[0].name + ", " + encounter_entity_list[1].name + ", " + encounter_entity_list[2].name + ".")
	print("////////////////////")
	turn_order = 0
#	----//----//----
#	------//END OF SUBROUTINES//------

#	ROUTINES
#	Encounter Arena Initiation Routine
func initiate_encounter():
	var arena = preloader.get_resource("Encounter").instance()
	add_child(arena)
#	----//----//----

#	Round Routine
func rotate_to_next_round():
	sort_current_round_turn_order()
	start_next_turn()
#	----//----//----

#	Turn Routine
func start_next_turn():
	print("////////////////////")
	if (turn_order + 1) > encounter_entity_list.size():
		current_round += 1
		rotate_to_next_round()
	else:
		encounter_entity_list[turn_order].run_turn()
#	----//----//----

#	Entity Response
func _on_pass_turn():
	turn_order += 1
	start_next_turn()

func _on_value_change_notice(obj, value, tipo):
	spawn_object(obj.global_position, "ValuePopUp", true, 0, value, tipo)
