extends Node

var picked_fish = 7-int(pow(randi()%7,1.3)*0.681555792)
var meals = 0

func _ready():
	get_node("../UI/HBoxContainer/fish_label").text = str(max(picked_fish,0))
	get_node("../UI/TextureRect").modulate.a8 = (230 - (3.5 * (pow(picked_fish+4,1.1))))
	
func increment_picked_fish():
	picked_fish += 1
	get_node("../UI/HBoxContainer/fish_label").text = str(max(picked_fish,0))
	if picked_fish <= 0:
		AudioManager.play_sound("eat",get_node("../Player"))
		get_node("../UI/starving").visible = picked_fish < 0
	get_node("../UI/TextureRect").modulate.a8 = (230 - (3.5 * (pow(picked_fish+4,1.1))))

func consume_fish():
	meals += 1
	$"../shake_manager".increment_combo(-7,picked_fish < 0)
	if meals%3 == 0:
		Transition.crossfade()
		get_node("../UI/HBoxContainer2/days_label").text = "WEEK "+str(int(meals/3))
		$"../shake_manager".increment_combo(int(picked_fish*.9)-picked_fish,picked_fish < 0)
		picked_fish = int(picked_fish*.95)
	picked_fish = max(picked_fish-7,-3)
	
	get_node("../UI/HBoxContainer/fish_label").text = str(max(picked_fish,0))
	get_node("../UI/starving").visible = picked_fish < 0
	get_node("../UI/TextureRect").modulate.a8 = (230 - (3.5 * (pow(picked_fish+4,1.1))))

func buffer_next_day():
	meals  = meals - meals%3 + 2
