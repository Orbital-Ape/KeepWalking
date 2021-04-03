extends Node2D

class_name Player


onready var administrator = get_node("/root/Main")
onready var tween = get_node("Tween")

var entity_spawn_id
var max_action_points
var ap
var initiative = 3
var speed = 4
var turn = false

func _ready():
	name = "Somar"
	max_action_points = initiative + speed
	ap = max_action_points

func run_turn():
	replenish_AP()
	turn = true

func _unhandled_input(event):
	if event is InputEventKey and turn:
		if event.pressed and event.scancode == KEY_SPACE:
			print("Consumed 3 AP")
			turn = false
			ap = clamp(ap - 3, 1, max_action_points)
			tween.interpolate_property($Sprite, "modulate", Color("#f70000"), Color("#ffffff"), 0.3, tween.TRANS_BACK, tween.EASE_IN)
			tween.start()

func replenish_AP():
	ap = clamp(ap + 2, 1, max_action_points)

func call_next_turn():
	administrator.turn_order += 1
	administrator.start_next_turn()

func _on_Tween_tween_completed(_object, _key):
	call_next_turn()
