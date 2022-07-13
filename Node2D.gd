extends KinematicBody2D
class_name base_entity

var velocity
var swim_power
var swim_lock
var input

func _physics_process(delta):
	process_swim_power(delta)
	process_movement(delta)

func process_swim_power(delta):
	input = get_movement_vector()
	if input.length() > 0:
		if (velocity.normalized()+input.normalized()).length() < 0.3:
			swim_power = max(swim_power,15.0)
			velocity *= -1.2
		elif (velocity.normalized()+input.normalized()).length() < .7:
			velocity *= -1.05
	
	if input.length() > 0.2:
		if swim_lock or swim_power <= 5.0:
			swim_lock = swim_power<10.0
			swim_power = int(min(swim_power+delta*85.0,12.0)*2)*.5
		else:
			swim_power = int(max(swim_power-input.length()*delta*10.0,4.5)*2)*.5
	else:
		swim_lock = false
		swim_power = int(min(swim_power+(1.0-input.length())*delta*110,14.50)*2)*.5

func process_movement(delta):
	if velocity.length() > 0.5:
		velocity *= .95
	elif input.length() > 0.15:
		velocity = (Vector2.RIGHT.rotated((velocity.normalized()+input.normalized()*3.0).angle())*.3)
	else:
		velocity = (Vector2.RIGHT.rotated(velocity.angle())*.3)
		
	velocity = (velocity+input*pow(swim_power,2.3)*delta*.2).length() * Vector2.RIGHT.rotated(((input).normalized() + velocity.normalized()*2.0).angle())
	
	$body.rotation = (velocity.normalized()*.3 + Vector2.RIGHT.rotated($body.rotation) + input.normalized()*.6).angle()
	$Sprite.frame = 2 - int(abs(velocity.length()) > 4.5)
	$Sprite.flip_h = velocity.x < 0
	
	move_and_slide(velocity * .10/delta)

func get_movement_vector():
	pass
