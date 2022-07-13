extends KinematicBody2D

var velocity
var boid_manager
var eid = 0
var dead = false
var weight = 1.0
var boid_type
var picked = false

func _ready():
	randomize()
	self_modulate = Color(1-randf()*(pow(eid%20,2.7)/10000.0),1-randf()*(pow(eid%20,2.7)/10000.0),1-randf()*(pow(eid%20,2.7)/10000.0)).lightened(.08)
	$Sprite.scale *= rand_range(0.9,1.1)

func _physics_process(delta):
	randomize()
	if not dead and randi()%8 == 1:
		$Sprite.frame = randi()%2
		$Sprite.flip_v = bool(randi()%2)
		boid_vector()
	else:
		if picked and randi()%5 == 1:
			call_deferred("free")
		velocity *= .99
		velocity.y += .2
		
	if velocity.length() > 1.0 and randi()%8 == 1:
		rotation = (velocity.normalized() + Vector2.RIGHT.rotated(rotation)).angle()
		
	#velocity = Vector2.RIGHT.rotated(( Vector2.RIGHT.rotated(rotation) + velocity.normalized()*2.0).angle()) * min(velocity.length(),40) * .97
	
	velocity = move_and_slide(velocity)
#	if $RayCast2D.is_colliding():
#		rotation += PI
#		velocity *= -.9
#		velocity += Vector2.RIGHT.rotated(rotation)

func boid_vector():
	randomize()
	var rand = randi()%int(pow(6,3))
	var v1 = boid_manager.velocity_rule(self) * [2,1.5,1,.5,0,-.5][int(rand/int(pow(6,3)))]
	var v2 = boid_manager.distance_rule(self) * [2,1.5,1,.5,0,-.5][int((rand%int(pow(6,2)))/pow(6,3))]
	var v3 = (boid_manager.centre_of_mass_rule(self) * [2,1.5,1,.5,0,-.5][int((rand%int(pow(6,1)))/pow(6,2))]).rotated(rand_range(0,-PI*.25))

	velocity = velocity + (v1 + v2 + v3)*.15
	
	velocity -= ((position-Vector2(80,80)).rotated(rand_range(0,PI*.1)).normalized()*pow((position-Vector2(80,80)).length(),1.7)/3000.0)
	
	if velocity.length() > .1:
		velocity = velocity.normalized() * max(velocity.length(),40) * .97
	else:
		velocity = Vector2.RIGHT.rotated(rotation) * max(velocity.length(),40) * .97

func die():
	if not dead:
		collision_layer = 5
		dead = true
		#boid_manager.boids.erase(str(eid))
		boid_manager.live_fish -= 1
		$Sprite.frame = 4
	velocity += Vector2.UP.rotated(rand_range(-PI,PI))*100
	velocity -= ((position-Vector2(80,80))/40.0).rotated(rand_range(0,PI*.1))
	position = ((position-Vector2(80,80))/1.1)+Vector2(80,80)

func _on_Area2D_area_entered(area):
	if (area.get_parent().eid == 0 and dead) or picked:
		if not picked:
			boid_manager.get_node("../shake_manager").increment_combo()
			collision_layer = 0
			velocity -= (area.get_parent().position - position) * .5
			picked = true
			get_node("../fish_economy").increment_picked_fish()
			boid_manager.boids.erase(str(eid))
			AudioManager.play_sound("pick_up",area)
