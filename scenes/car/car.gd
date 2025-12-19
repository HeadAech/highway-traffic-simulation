class_name Car extends CharacterBody3D

var _velocity_z
var current_acceleration : float = 0

var max_acceleration : float = 0.0
var max_deacceleration : float = 0.0
var max_velocity : float = 0.0
var random_threshold_factor : float = 1

var driver_type: Global.DriverType = Global.DriverType.MEDIOCRE

var politeness_factor : float = 1
var decision_threshold : float = 1


# Multipliers for (acceleration & deacceleration) | (velocity)
var driver_acc_dcc_multiplier : float
var driver_velocity_multiplier : float

var possible_leaders = []
var current_leader

var is_merging : bool = false
var during_merge : bool = false
var can_merge : bool = false
var merging_x_distance : float = 9.8
var pre_merge_position : float
var post_merge_position : float
var merge_boost_flag : bool = false

var possible_mergers = []
var current_ta : Car
var future_la : Car

var deacceleration_flag = false
var has_braked = false
var can_brake = false
var braking_affected_by_merge = false



@export var area3d : Area3D
@onready var car_body: Node3D = $"Car Model/Body"
@export var is_frozen : bool = false

var unique_material: StandardMaterial3D
@onready var brake_light: SpotLight3D = $BrakeLight
@onready var turn_indicator: SpotLight3D = $TurnIndicator
@onready var turn_indicator_animation_player: AnimationPlayer = $TurnIndicatorAnimationPlayer

func _ready():
	if not is_frozen:
		var current_material = car_body.get_active_material(0)
		unique_material = current_material.duplicate()
		car_body.set_surface_override_material(0, unique_material)
		$HoverColor.set_surface_override_material(0, unique_material)

		random_threshold_factor = Global.random_threshold_factor

		politeness_factor = Global.politeness_factor * (((9.0 + driver_type)  / 10.0))
		decision_threshold = Global.decision_threshold / (((9.0 + driver_type)  / 10.0))

		driver_acc_dcc_multiplier = (1.0 + driver_type)  / 2.0
		driver_velocity_multiplier = (9.0 + driver_type)  / 10.0
		max_velocity = Global.base_velocity * driver_velocity_multiplier
		velocity.z = max_velocity

		max_acceleration = Global.base_acceleration * driver_acc_dcc_multiplier
		max_deacceleration = Global.base_deacceleration * driver_acc_dcc_multiplier
		current_acceleration = max_acceleration

		$Area3D.get_node("CollisionShape3D").shape.size.z = Global.desired_gap
		$Area3D.get_node("CollisionShape3D").position.z = 3.5 + Global.desired_gap / 2.0

		turn_indicator.hide()
		turn_indicator_animation_player.play("RESET")
		if is_merging:
			pre_merge_position = global_position.x
			post_merge_position = pre_merge_position + merging_x_distance


func _physics_process(_delta: float) -> void:
	if (can_merge and is_merging) or during_merge:
		turn_indicator_animation_player.play("blink")
	else:
		turn_indicator_animation_player.play("RESET")

	if not is_frozen:
		recolor(driver_type)

		if during_merge:
			if current_ta:
					current_ta.current_leader = self
			if possible_leaders.size() > 0:
				var counter = 0
				if possible_leaders[0] != self:
					current_leader = possible_leaders[0]
					counter += 1
				elif possible_leaders.size() >= 2 and possible_leaders[1] != self:
					current_leader = possible_leaders[1]
					counter += 1
				for i in range(counter, possible_leaders.size()):
					if possible_leaders[i] == self:
						continue
					if current_leader.global_position.z > possible_leaders[i].global_position.z:
						current_leader = possible_leaders[i]
			var future_gap_to_leader = INF
			var future_leader_velocity = 0
			if future_la:
				future_gap_to_leader = abs(future_la.global_position.z - global_position.z)
				future_leader_velocity = future_la.velocity.z
			elif current_leader and current_leader.is_frozen:
				future_gap_to_leader = abs(current_leader.global_position.z - global_position.z) / 2
				future_leader_velocity = 0

			current_acceleration = calculate_acceleration(velocity.z, future_leader_velocity, future_gap_to_leader)
			
			velocity.z += current_acceleration
			if velocity.z < 0.01: 
				velocity.z += 1.0
			if global_position.x < post_merge_position:
				velocity.x = velocity.z / sqrt(2)
			else:
				current_leader = future_la
				Signals.emit_signal("MergeLane",self)
				global_position.x = post_merge_position
				during_merge = false
				velocity.x = 0.0
		else:
			if not can_merge: turn_indicator_animation_player.play("RESET")
			if position.x != 0.0:
				position.x = 0.0
				position.z -= Global.minimum_gap * 2

			var current_gap_to_leader = INF
			var current_leader_velocity = 0
			if current_leader != null:
					current_gap_to_leader = abs(current_leader.global_position.z - global_position.z)
					current_leader_velocity = current_leader.velocity.z

			if deacceleration_flag or braking_affected_by_merge:
				if braking_affected_by_merge:
					if current_leader:
						if !current_leader.during_merge or abs(current_leader.global_position.z - global_position.z) > Global.desired_gap:
							braking_affected_by_merge = false
					else:
						braking_affected_by_merge = false
				brake_light.show()
				velocity.z = move_toward(velocity.z, 0.0, max_deacceleration)
				current_acceleration = 0
			else:
				brake_light.hide()
				var counter = 0
				if possible_leaders.size() > 0:
					if possible_leaders[0] != self:
						current_leader = possible_leaders[0]
						counter += 1
					elif possible_leaders.size() >= 2 and possible_leaders[1] != self:
						current_leader = possible_leaders[1]
						counter +=1
					for i in range(counter, possible_leaders.size()):
						if possible_leaders[i] == self:
							continue
						if current_leader.global_position.z > possible_leaders[i].global_position.z:
							current_leader = possible_leaders[i]
				current_acceleration = calculate_acceleration(velocity.z, current_leader_velocity, current_gap_to_leader)
				velocity.z += current_acceleration

				if is_merging and can_merge:
					attempt_merge()

			if current_gap_to_leader < velocity.z + current_acceleration:
				if current_gap_to_leader <= Global.minimum_gap:
					velocity.z = 0.0
					current_acceleration = 0.0

		velocity.z = max(min(velocity.z, max_velocity),0.0)
		velocity.x = max(min(velocity.x, max_velocity),0.0)
		_velocity_z = velocity.z
		# 2.4.4 Move
		move_and_slide()



# recolor for identification
func recolor(new_type : Global.DriverType):
	match new_type:
		Global.DriverType.CALM:
			unique_material.albedo_color = (Color(1,1,0))
		Global.DriverType.MEDIOCRE:
			unique_material.albedo_color = (Color(1,0.5,0))
		Global.DriverType.AGGRESSIVE:
			unique_material.albedo_color = (Color(1,0,0))

func attempt_merge():
	if get_parent().get_children()[1] == self:

		var possible_ta = null
		var possible_la = null

		var gap_to_ta = INF
		var gap_to_la = INF


		for i in range(0, possible_mergers.size()):

			if possible_mergers[i] == self:
				continue

			var signed_gap = possible_mergers[i].global_position.z - global_position.z
			var abs_gap = abs(signed_gap)
			if signed_gap > 0:
				if abs_gap < gap_to_la:
					gap_to_la = abs_gap
					possible_la = possible_mergers[i]
			else:
				if abs_gap < gap_to_ta:
					gap_to_ta = abs_gap
					possible_ta = possible_mergers[i]
		future_la = possible_la
		current_ta = possible_ta

		var future_la_position = INF
		var current_ta_velocity = 0
		var ta_gap_old_la = INF
		var future_la_velocity = 0
		var ta_gap_new_la = gap_to_ta

		if future_la:
			future_la_position = future_la.global_position.z
			future_la_velocity = future_la.velocity.z
		else:
			future_la_velocity = 0

		if current_ta:
			current_ta_velocity = current_ta.velocity.z
			if current_ta.deacceleration_flag:
				current_ta_velocity = 0

		if future_la and current_ta:
			ta_gap_old_la = abs(future_la.global_position.z - current_ta.global_position.z)


		if (
			#gap_to_ta < Global.minimum_gap
			gap_to_la < Global.minimum_gap
			or gap_to_la + future_la_velocity < Global.minimum_gap + velocity.z
			##or gap_to_ta + current_ta_velocity < Global.minimum_gap + velocity.z
		):
			return
		if future_la:
			if future_la.deacceleration_flag:
				return

		if check_lane_change(future_la_position, future_la_velocity, current_ta_velocity, ta_gap_old_la, future_la_velocity, ta_gap_new_la, velocity.z):
			is_merging = false
			can_merge = false
			during_merge = true
			if current_ta:
				current_ta.braking_affected_by_merge = true

## Calculates desired acceleration.
## 'v' is vehicle speed.
## 'vl' is LA speed.
## 's' is current gap to LA.
func calculate_acceleration(v: float, vl: float, s: float) -> float:
	if s < 0.1:
		s = 0.1
	# s* calc - optimal/desired gap
	# Need check to what - comfort deacceleration means exactly
	var desired_gap_part : float
	var desired_gap : float
	desired_gap_part = (v * (v - vl)) / (2.0 * sqrt(max_acceleration * max_deacceleration))
	desired_gap = Global.minimum_gap + (v * Global.desired_headway) + desired_gap_part

	# v dot (acceleration) calc
	var term_speed = pow(v / max_velocity, 4)

	var term_gap
	if is_inf(s):
		term_gap = 0.0
	else:
		term_gap = pow(desired_gap / s, 2)
	var acceleration = max_acceleration * (1.0 - term_speed - term_gap)

	if acceleration < -max_deacceleration:
		acceleration = -max_deacceleration

	return acceleration

## Call when needed to check whether it is possible to change or not
## returns true when possible
func check_lane_change(
		# State if [TA's LA]
		la_z_cord: float,
		la_velocity: float,
		# State of TA
		ta_velocity: float,
		# TA Old State
		ta_gap_to_old_leader: float,
		ta_velocity_of_old_leader: float,
		# TA New State
		ta_gap_to_new_leader: float,
		ta_velocity_of_new_leader: float
	) -> bool:


	var a_old_ma
	var a_new_ma

	a_old_ma = current_acceleration
	a_new_ma = calculate_acceleration(velocity.z, la_velocity, abs(la_z_cord - global_position.z))

	#if a_new_ma < -max_deacceleration:
		#return false

	#var predicted_gap = abs(la_z_cord - global_position.z) - (velocity.z - la_velocity)
	#if predicted_gap < Global.minimum_gap:
		#return false

	var delta_a_ma = a_new_ma - a_old_ma

	var a_old_ta
	var a_new_ta
	if current_ta:
		a_old_ta = current_ta.current_acceleration
		a_new_ta = calculate_acceleration(current_ta.velocity.z, velocity.z, abs(current_ta.global_position.z - global_position.z))
	else:
		a_new_ta = 0
		a_old_ta = 0


	var delta_a_ta = a_new_ta - a_old_ta

	# Calculate total incentive
	var car_politeness_factor = 100.0
	if current_ta:
		car_politeness_factor = current_ta.politeness_factor
	var incentive = delta_a_ma + car_politeness_factor * delta_a_ta

	return incentive > decision_threshold


# Check whether this driver has gained any potential LA
func _on_area_3d_body_entered(body):
	possible_leaders.append(body)

# Check whether this driver has lost its LA
func _on_area_3d_body_exited(body):
	possible_leaders.erase(body)
	if body == current_leader:
		current_leader = null


func _on_merging_area_body_entered(body):
	if body is not StaticBody3D and is_merging:
		possible_mergers.append(body)

func _on_merging_area_body_exited(body):
	if body is not StaticBody3D and is_merging:
		possible_mergers.erase(body)
		if body == future_la:
			future_la = null
		elif body == current_ta:
			current_ta = null


func _on_mouse_entered():
	$HoverColor.visible = true


func _on_mouse_exited():
	$HoverColor.visible = false


func _input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			deacceleration_flag = not deacceleration_flag

			if deacceleration_flag:
				$DeaccelerationTimer.start()
				has_braked = true
				can_brake = false
			else:
				$DeaccelerationTimer.stop()

func _on_deacceleration_timer_timeout():
	deacceleration_flag = false


func _on_brake_timer_timeout():
	can_brake = true
