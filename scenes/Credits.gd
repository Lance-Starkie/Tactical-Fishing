extends Node2D
var counter = 0

func _on_Timer_timeout():
	AudioManager.play_sound("hit",AudioManager)
	counter += 1	
	if counter >= 5:
		get_tree().change_scene("res://scenes/main.tscn")
