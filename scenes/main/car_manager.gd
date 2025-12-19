extends Node

const TOTAL: float = 100.0

@export var car_scene: PackedScene

# Anti freeze loop precaution
var is_updating: bool = false

@export_group("Lane Setup")
@export var lane1_node: Node
@export var lane2_node: Node
@export var lane3_node: Node
@export var lane4_node: Node

var lane1_cars: Array = []
var lane2_cars: Array = []
var lane3_cars: Array = []
var lane4_cars: Array = []

var lane_nodes: Array[Node] = []
var lane_car_lists: Array = []
var lane_weights: Array[float] = []

# Target percentages for each driver type
var _car_type_calm: float = 20.0
var _car_type_mediocre: float = 60.0
var _car_type_aggressive: float = 20.0

# Stores amount of drivers/cars of each type
var car_type_counts: Array[int] = [0, 0, 0]
var stop_spawning_cars = false

func _ready():
	Signals.DeleteCar.connect(deregister_car)
	Signals.MergeLane.connect(merge_lane)
	Signals.UpdateCars.connect(update_cars)
	Signals.ResetSimulation.connect(reset_simulation)
	lane_nodes = [lane1_node, lane2_node, lane3_node, lane4_node]
	lane_car_lists = [lane1_cars, lane2_cars, lane3_cars, lane4_cars]
	lane_weights = [Global.lane1_weight, Global.lane2_weight, Global.lane3_weight, Global.lane4_weight]


func _process(_delta):
	var sum_of_cars = 0
	for i in lane_car_lists:
		sum_of_cars += i.size()

	if not stop_spawning_cars and sum_of_cars < Global.drivers_on_road_amount:
		assign_new_car()


## Creates and assigns a new car to random (weighted) lane
func assign_new_car():
	var lane_id = _get_weighted_random_index(lane_weights)

	var new_car : Car = car_scene.instantiate()

	if lane_id == 3:
		new_car.is_merging = true
		new_car.has_braked = true
		new_car.can_brake = false

	new_car.driver_type = register_car()
	var spawn_pos_z = lane_nodes[lane_id].global_position.z

	if not lane_car_lists[lane_id].is_empty():
		var last_car = lane_car_lists[lane_id].back()

		var safe_z = last_car.global_position.z - (Global.desired_gap * 2)

		if safe_z < spawn_pos_z:
			spawn_pos_z = safe_z

	new_car.velocity = Vector3.ZERO
	new_car.velocity.z = Global.base_velocity
	lane_car_lists[lane_id].append(new_car)
	lane_nodes[lane_id].add_child(new_car)
	new_car.position.x = 0.0
	new_car.global_position.z = spawn_pos_z

## Registers a car, call it whenever car is created
func register_car() -> Global.DriverType:
	var total_cars = car_type_counts[Global.DriverType.CALM] + \
					 car_type_counts[Global.DriverType.MEDIOCRE] + \
					 car_type_counts[Global.DriverType.AGGRESSIVE]

	var next_type: Global.DriverType

	if total_cars == 0:
		# if no cars, then gamba time
		var driver_weights: Array[float]= [_car_type_calm, _car_type_mediocre, _car_type_aggressive]
		next_type = _get_weighted_random_index(driver_weights) as Global.DriverType
	else:

		var current_calm_pct = (float(car_type_counts[Global.DriverType.CALM]) / total_cars) * 100.0
		var current_mediocre_pct = (float(car_type_counts[Global.DriverType.MEDIOCRE]) / total_cars) * 100.0
		var current_aggresive_pct = (float(car_type_counts[Global.DriverType.AGGRESSIVE]) / total_cars) * 100.0

		var calm_need = _car_type_calm - current_calm_pct
		var mediocre_need = _car_type_mediocre - current_mediocre_pct
		var aggresive_need = _car_type_aggressive - current_aggresive_pct

		if calm_need >= mediocre_need and calm_need >= aggresive_need:
			next_type = Global.DriverType.CALM
		elif mediocre_need >= calm_need and mediocre_need >= aggresive_need:
			next_type = Global.DriverType.MEDIOCRE
		else:
			next_type = Global.DriverType.AGGRESSIVE

	car_type_counts[next_type] += 1

	return next_type



## deregisters a car, whenever it leaves our road (if we decide to do so instead of looping)
func deregister_car(car : Car):
	var type = car.driver_type
	car_type_counts[type] = max(0, car_type_counts[type] - 1)

	var car_parent = car.get_parent()

	for item in lane_car_lists:
		if item != null:
			item.erase(car)

	car_parent.remove_child(car)
	car.free()
	pass


func merge_lane(car : Car):
	var global_pos_value = car.global_position
	for item in lane_car_lists:
		if item != null:
			item.erase(car)
	lane_car_lists[2].append(car)
	car.reparent($"Lane 3")
	car.global_position = global_pos_value



## Returns a random index based on given weights
func _get_weighted_random_index(weights: Array[float]) -> int:
	var total_weight: float = 0.0
	for w in weights:
		total_weight += w

	if total_weight <= 0.0:
		return randi_range(0, weights.size() - 1)

	var random_pick: float = randf_range(0.0, total_weight)
	var current_weight: float = 0.0

	for i in range(weights.size()):
		current_weight += weights[i]
		if random_pick < current_weight:
			return i

	return weights.size() - 1

# They do not need to be exported here, just make a slider in gui and we gucci.
@export_group("Target Ratios")
@export_range(0, 100, 1) var car_type_calm: float:
	get: return _car_type_calm
	set(new_value):
		_redistribute(Global.DriverType.CALM, new_value)

@export_range(0, 100, 1) var car_type_mediocre: float:
	get: return _car_type_mediocre
	set(new_value):
		_redistribute(Global.DriverType.MEDIOCRE, new_value)

@export_range(0, 100, 1) var car_type_aggresive: float:
	get: return _car_type_aggressive
	set(new_value):
		_redistribute(Global.DriverType.AGGRESSIVE, new_value)


func _redistribute(changed_type: Global.DriverType, new_value: float):
	if is_updating:
		return
	is_updating = true

	var clamped_value = clamp(new_value, 0, TOTAL)
	match changed_type:
		Global.DriverType.CALM:
			_car_type_calm = clamped_value
		Global.DriverType.MEDIOCRE:
			_car_type_mediocre = clamped_value
		Global.DriverType.AGGRESSIVE:
			_car_type_aggressive = clamped_value

	var old1: float
	var old2: float
	match changed_type:
		Global.DriverType.CALM:
			old1 = _car_type_mediocre
			old2 = _car_type_aggressive
		Global.DriverType.MEDIOCRE:
			old1 = _car_type_calm
			old2 = _car_type_aggressive
		Global.DriverType.AGGRESSIVE:
			old1 = _car_type_calm
			old2 = _car_type_mediocre

	var new_sum_others = TOTAL - clamped_value
	var old_sum_others = old1 + old2

	var new1: float
	var new2: float

	if old_sum_others == 0 or old1 == 0 or old2 == 0:
		new1 = round(new_sum_others / 2.0)
		new2 = new_sum_others - new1
	else:
		var ratio1 = old1 / old_sum_others
		new1 = round(new_sum_others * ratio1)
		new2 = new_sum_others - new1

	match changed_type:
		Global.DriverType.CALM:
			_car_type_mediocre = new1
			_car_type_aggressive = new2
		Global.DriverType.MEDIOCRE:
			_car_type_calm = new1
			_car_type_aggressive = new2
		Global.DriverType.AGGRESSIVE:
			_car_type_calm = new1
			_car_type_mediocre = new2

	is_updating = false
	notify_property_list_changed.call_deferred()

func _on_end_body_entered(body):
	Signals.DeleteCar.emit(body)


func _on_merge_dissalow_area_body_exited(body):
	body.can_merge = true


func update_cars():
	for line in lane_car_lists:
		for car in line:
			if not car.is_frozen:
				var current_material = car.car_body.get_active_material(0)
				car.unique_material = current_material.duplicate()
				car.car_body.set_surface_override_material(0, car.unique_material)

				car.random_threshold_factor = Global.random_threshold_factor

				car.decision_threshold = Global.decision_threshold / (((9.0 + car.driver_type)  / 10.0))


				car.driver_acc_dcc_multiplier = (1.0 + car.driver_type)  / 2.0
				car.driver_velocity_multiplier = (9.0 + car.driver_type)  / 10.0
				car.max_velocity = Global.base_velocity * car.driver_velocity_multiplier

				car.max_acceleration = Global.base_acceleration * car.driver_acc_dcc_multiplier
				car.max_deacceleration = Global.base_deacceleration * car.driver_acc_dcc_multiplier

func reset_simulation():
	stop_spawning_cars = true
	for car_list in [lane1_cars, lane2_cars, lane3_cars, lane4_cars]:
		car_list.clear()

	for lane in lane_nodes:
		for node in lane.get_children():
			if node is Car:
				node.queue_free()

	stop_spawning_cars = false
	car_type_counts = [0, 0, 0]
