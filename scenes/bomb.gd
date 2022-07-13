extends KinematicBody2D

var velocity = Vector2.ZERO
var boid_manager
var eid
export var weight = 1.5
var dead = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("bomb")
	$AnimationPlayer.queue("float")
	$pain/hitbox.shape.radius = 3
	velocity += Vector2.RIGHT.rotated(rand_range(-PI,PI))*10

func _physics_process(delta):
	velocity *= .93
	velocity = move_and_slide(velocity)

func _on_pain_area_entered(area):
	if $AnimationPlayer.current_animation == "float":
		boid_manager.shake(.5)
		$AnimationPlayer.play("explode")
		$explosion.emitting = true
		$bubbles.emitting = true
		move_and_slide(velocity.normalized()*200.0)

func die():
	pass
	
func hitbox():
	$pain/hitbox.shape.radius = 25
	for colliding_area in $pain.get_overlapping_areas():
		colliding_area.get_parent().die()

func remove_object():
	call_deferred("free")

func play_sound(sound: String):
	AudioManager.play_sound(sound,self)
