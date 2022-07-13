extends AudioStreamPlayer2D

func _ready():
	play()
	
func _process(_delta):
	if playing == false:
		call_deferred('free')
