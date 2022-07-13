extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _ready():
	fade_in()

# Called when the node enters the scene tree for the first time.
func fade_in():
	$AnimationPlayer.play("fade_in")

func fade_out():
	$AnimationPlayer.play("fade_out")
	
func crossfade():
	$AnimationPlayer.play("fade_out")
	$AnimationPlayer.queue("fade_in")
