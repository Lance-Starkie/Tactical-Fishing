extends KinematicBody2D

var velocity := Vector2.ZERO
var swim_power := 0.0
var swim_lock = false
var pl_bomb = preload("res://scenes/mine.tscn")
var dead = false
var weight = 5.0
var eid = 0
var energy = 100.0
var input

func _physics_process(delta):
	if randi()%5 == 1:
		$camera_head.position = ($camera_head.position + velocity.normalized() * 6)/2

	input = get_movement_vector()
	if not dead:
		randomize()
		
		process_player_actions()
		
		process_swim_power(delta)
		
		#Hunger handling
		if energy <= 0:
			if get_node("../fish_economy").picked_fish < 0:
				starve()
			else:
				energy = 100
				get_node("../fish_economy").consume_fish()
				AudioManager.play_sound("eat",self)
				$AnimationPlayer.play("eat")
		
		#Sprite display
		$body.rotation = (velocity.normalized()*.3 + Vector2.RIGHT.rotated($body.rotation) + input.normalized()*.6).angle()
		$Sprite.frame = 2 - int(abs(velocity.length()) > 4.5)
		$Sprite.flip_h = velocity.x < 0
		
		#Player movement
		velocity = ((velocity+input*pow(swim_power,2.3)*delta*.2).length()
			* Vector2.RIGHT.rotated(
				((input).normalized() + velocity.normalized()*2.0).angle())
			)
	
	if velocity.length() > 0.5:
		velocity *= .95
	elif input.length() > 0.15:
		velocity = (Vector2.RIGHT.rotated((velocity.normalized()+input.normalized()*3.0).angle())*.3)
	else:
		velocity = (Vector2.RIGHT.rotated(velocity.angle())*.3)

	move_and_slide(velocity * .10/delta)

func process_swim_power(delta):
	if input.length() > 0:
		if randi()%(1+get_node("../boid_manager").live_fish*40) == 1:
			get_node("../fish_economy").buffer_next_day()
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

func process_player_actions():
		if Input.is_action_just_pressed("dodge_button"):
			input *= -1
			input = input.rotated(rand_range(-1,1))
			energy -= 5
		elif Input.is_action_pressed("dodge_button") and randi()%15 == 0:
			velocity *= 1.3
			energy -= .2 * velocity.length()/8.0
		else:
			energy -= .1 * velocity.length()/8.0
			
		if Input.is_action_just_pressed("light"):
			energy -= 1
			place_bomb()

func place_bomb():
	$throw.emitting = true
	AudioManager.play_sound("hit",self)
	$"../shake_manager".shake(.1)
	var bomb = pl_bomb.instance()
	bomb.position = position - $camera_head.position
	bomb.boid_manager = get_node("../boid_manager")
	bomb.velocity = (velocity.normalized() + get_movement_vector()) * (velocity.length()*.5 + 65)
	velocity = (velocity.normalized() + get_movement_vector()) * (velocity.length()*.5 + 65)*-0.05
	get_parent().add_child(bomb)
	
	get_node("../boid_manager").fish += 1
	get_node("../boid_manager").boids[str(get_node("../boid_manager").fish)] = bomb
	bomb.eid = get_node("../boid_manager").fish

func die():
	$"../shake_manager".shake(.9)
	dead = true
	$AnimationPlayer.play("death")
	velocity += Vector2.UP.rotated(rand_range(-PI,PI))*10

func starve():
	$"../shake_manager".shake(-5)
	dead = true
	$AnimationPlayer.play("starve")
	velocity = velocity.normalized()*5.0

func play_sound(sound):
	AudioManager.play_sound(sound,self)

func clear_entity():
	get_tree().reload_current_scene()

func get_movement_vector():
	return get_player_input()[0]

func get_player_input():
	return [
		Vector2 (
			clamp(Input.get_action_strength("joy_right") - Input.get_action_strength("joy_left"),-1,1),
			clamp(Input.get_action_strength("joy_down") - Input.get_action_strength("joy_up"),-1,1)
		).normalized(),
		Vector2 (
			clamp(Input.get_action_strength("dodge_right") - Input.get_action_strength("dodge_left"),-1,1),
			clamp(Input.get_action_strength("dodge_down") - Input.get_action_strength("dodge_up"),-1,1)
		).normalized(),
		max (
			max(
				Input.get_action_strength("light"),
				Input.get_action_strength("heavy")*2
			),
			max(
				Input.get_action_strength("special")*4,
				Input.get_action_strength("dodge_button")*8
			)
		)
	]
