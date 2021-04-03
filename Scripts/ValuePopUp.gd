extends Label


onready var tween = get_node("Tween")


func _ready():
	tween.interpolate_property(self, "rect_position", rect_position, rect_position + Vector2(0, -16), 0.8, tween.TRANS_BACK, tween.EASE_OUT)
	tween.start()
	
func _on_Tween_tween_all_completed():
	print("Free!!")
	queue_free()
