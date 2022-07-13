extends Node

onready var viewport := $"../Player/camera_head/Camera2D"

var magnitude = 0
var combo = 0
var starving = false

func shake(in_magnitude):
	magnitude += max(0,in_magnitude*2.5)

func _physics_process(delta):
	magnitude *= .8
	randomize()
	viewport.offset_v = rand_range(-1,1)*magnitude
	randomize()
	viewport.offset_h = rand_range(-1,1)*magnitude

func increment_combo(count = 1,in_starving = false):
	combo += count
	
	starving = in_starving
	if in_starving:
		if combo > 0:
			get_node("../UI/combo_timer").text = "+"+str(combo)
		elif combo < -3:
			get_node("../UI/combo_timer").text = str(combo) + "*"
		else:
			get_node("../UI/combo_timer").text = str(combo)
	else:
		if combo > 0:
			get_node("../UI/combo_timer").text = "+"+str(combo)
		elif combo < 0:
			get_node("../UI/combo_timer").text = str(combo)
		else:
			get_node("../UI/combo_timer").text = ""
		get_node("../UI/combo_timer/Timer").start()

func _on_Timer_timeout():
	if not starving:
		combo = 0
		get_node("../UI/combo_timer").text = ""
