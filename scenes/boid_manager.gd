extends Node

var pl = {
	"fish":preload("res://scenes/fish_boid.tscn")
	}
var boids := {}
var fish = 0
var pattern = randi()%40
var live_fish = 0

func _ready():
	boids[str(fish)] = get_node("../Player")
	fish += 1

func _process(delta):
	if live_fish < (pattern%50)+2:
		for i in range(0,(pattern%50)+2-live_fish):
			if live_fish > 40:
				pass
			randomize()
			add_boid("fish",
				Vector2(
					1,
					0
				).rotated(rand_range(-PI,PI))*(randi()%25+75) + Vector2(
					80,
					80
				),
				Vector2(
					1,
					0
				).rotated(rand_range(-PI,PI)*(randi()%25)+25)
			)
		if randi()%99 < 5:
			pattern += randi()%70
			pattern = pattern%(50-randi()%13)

func shake(mag):
	$"../shake_manager".shake(mag)

func add_boid(type, in_position, in_velocity):
	live_fish += 1
	var boid = pl[type].instance()
	fish += 1
	boids[str(fish)]=boid
	boid.eid = fish
	boid.boid_manager = self
	boid.position = in_position
	boid.velocity = in_velocity
	get_parent().call_deferred("add_child",boid)

func centre_of_mass_rule(in_boid):
	var perceived_center = Vector2.ZERO

	randomize()
	for boid in boids:
		if is_instance_valid(boids[boid]):
			if boids[boid].eid%3 in [randi()%3,0]:
				if boids[boid].eid != in_boid.eid:
					perceived_center += boids[boid].position*boids[boid].weight

	perceived_center = perceived_center/ (boids.size()-1)

	return (perceived_center - in_boid.position) / 8.0
	
func distance_rule(in_boid):
	
	var perceived_velocity: Vector2
	var displacement := Vector2.ZERO
	
	randomize()
	for boid in boids:
		if is_instance_valid(boids[boid]):
			if boids[boid].eid%3 in [randi()%3,0] and not boids[boid].eid in [0,randi()%30] :
				if boids[boid].eid != in_boid.eid:
					if (boids[boid].position - in_boid.position).length() < 20:
						if boids[boid].dead:
							displacement += (boids[boid].position - in_boid.position)*boids[boid].weight*1.3*pow((20-(boids[boid].position - in_boid.position).length()),2)/20
							perceived_velocity += boids[boid].velocity*boids[boid].weight*1.5
						else:
							displacement -= (boids[boid].position - in_boid.position)*boids[boid].weight*pow((20-(boids[boid].position - in_boid.position).length()),2)/20
							perceived_velocity += boids[boid].velocity*boids[boid].weight

	perceived_velocity = perceived_velocity / (boids.size()-1)

	return displacement + (perceived_velocity - in_boid.velocity) / 8.0
	
func velocity_rule(in_boid):
	var perceived_velocity: Vector2

	randomize()
	for boid in boids:
		if is_instance_valid(boids[boid]):
			if boids[boid].eid%2 in [randi()%2,0]:
				if boids[boid].eid != in_boid.eid:
					perceived_velocity += boids[boid].velocity*boids[boid].weight
	
	perceived_velocity = perceived_velocity / (boids.size()-1)
	
	$"../UI".offset = ($"../UI".offset*4+perceived_velocity.normalized())/5.0

	return (perceived_velocity - in_boid.velocity) / 2.0
