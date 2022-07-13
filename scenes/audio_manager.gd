extends Node
class_name audio

var playing = true

var pl_audio := preload("res://scenes/AudioSource.tscn")

func play_sound(sound,source,pitch = null,music = false):
	if playing:
		var audio = pl_audio.instance()
		audio.stream = load("res://sounds/{sound}.wav".format({"sound": sound}))
		audio.pitch_scale = rand_range(.8,1.2)
		source.call_deferred("add_child",audio)	
		return audio

