extends Area3D

var braking_car : Car
var timer : Timer
var brake_cooldown = true

func _ready():
	timer = Timer.new()
	add_child(timer)
	
	brake_cooldown = false
	timer.wait_time = randf_range(5.0,10.0)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	
func _process(_delta):
	if (brake_cooldown) and (braking_car == null or braking_car.deacceleration_flag == false):
		var bodies = get_overlapping_bodies()
		var brake_threshold = Global.random_threshold_factor
		var random_braking_value = randf_range(0.0,1.0)
		if (random_braking_value > brake_threshold) and (bodies != []):
			while bodies.size() > 0:
				var car : Car = bodies.pick_random()
				bodies.erase(car)
				if car.can_brake and not car.has_braked and not car.braking_affected_by_merge:
					car.can_brake = false
					car.has_braked = true
					car.deacceleration_flag = true
					car.current_acceleration = 0
					braking_car = car
					brake_cooldown = false
					
					car.get_node("DeaccelerationTimer").start()
					timer.wait_time = randf_range(5.0,10.0)
					timer.start()
					break
					
func _on_timer_timeout():
	brake_cooldown = true
	
func _on_body_entered(body : Car):
	if body.during_merge:
		pass
	else:
		body.get_node("BrakeTimer").wait_time = randf_range(2.0,8.0)
		body.get_node("BrakeTimer").start()
