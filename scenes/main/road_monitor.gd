extends Node

@export var main_road : Node3D
var time_spent = 0

var section_array = []
var density_array = []
var flow_array    = []


const ROWS = 3
const COLS = 56

const TABLE_VALUE = preload("uid://bag82paaeam8n")

@onready var flow_sector_numbers: HBoxContainer = $"Control/MarginContainer/Monitor/TabContainer/Flow/MarginContainer/HBoxContainer/VBoxContainer/Values/Sector Numbers"
@onready var flow_lane_1: HBoxContainer = $"Control/MarginContainer/Monitor/TabContainer/Flow/MarginContainer/HBoxContainer/VBoxContainer/Values/Lane 1 Values"
@onready var flow_lane_2: HBoxContainer = $"Control/MarginContainer/Monitor/TabContainer/Flow/MarginContainer/HBoxContainer/VBoxContainer/Values/Lane 2 Values"
@onready var flow_lane_3: HBoxContainer = $"Control/MarginContainer/Monitor/TabContainer/Flow/MarginContainer/HBoxContainer/VBoxContainer/Values/Lane 3 Values"

@onready var density_sector_numbers: HBoxContainer = $"Control/MarginContainer/Monitor/TabContainer/Density/MarginContainer/HBoxContainer/VBoxContainer/Values/Sector Numbers"
@onready var density_lane_1: HBoxContainer = $"Control/MarginContainer/Monitor/TabContainer/Density/MarginContainer/HBoxContainer/VBoxContainer/Values/Lane 1 Values"
@onready var density_lane_2: HBoxContainer = $"Control/MarginContainer/Monitor/TabContainer/Density/MarginContainer/HBoxContainer/VBoxContainer/Values/Lane 2 Values"
@onready var density_lane_3: HBoxContainer = $"Control/MarginContainer/Monitor/TabContainer/Density/MarginContainer/HBoxContainer/VBoxContainer/Values/Lane 3 Values"


@onready var update_table: Timer = $"Update Table"

func _ready():
	Signals.ResetSimulation.connect(_ready)
	for arr in [section_array, density_array, flow_array]:
		arr.resize(ROWS)
		for row in ROWS:
			arr[row] = []
			arr[row].resize(COLS)
			arr[row].fill(0)
	$Timer.start()
	_fill_monitor_table()

func _process(_delta):
	pass

func _fill_monitor_table():

	var flow_lanes = [flow_lane_1, flow_lane_2, flow_lane_3]
	var density_lanes = [density_lane_1, density_lane_2, density_lane_3]

	# flow
	# fill in sector numbers
	for child in flow_sector_numbers.get_children():
		child.queue_free()

	for i in range(COLS - 1):
		var val: TableValue = TABLE_VALUE.instantiate()
		val.is_header = true
		val.set_value(i)
		flow_sector_numbers.add_child(val)

	# clear any residue in flow
	for c in flow_lanes:
		for child in c.get_children():
			child.queue_free()

		# fill in blank values
		for i in range(COLS - 1):
			var val: TableValue = TABLE_VALUE.instantiate()
			val.set_value(0)
			c.add_child(val)

	# density
	for child in density_sector_numbers.get_children():
		child.queue_free()

	for i in range(COLS - 1):
		var val: TableValue = TABLE_VALUE.instantiate()
		val.is_header = true
		val.set_value(i)
		density_sector_numbers.add_child(val)

	# clear any residue in flow
	for c in density_lanes:
		for child in c.get_children():
			child.queue_free()

		# fill in blank values
		for i in range(COLS - 1):
			var val: TableValue = TABLE_VALUE.instantiate()
			val.set_value(0)
			c.add_child(val)

func _on_timer_timeout():
	time_spent += 1.0
	for i in main_road.lane_car_lists.size():
		for car in main_road.lane_car_lists[i]:
			if car:
				var position_z_in_section = ceil(car.global_position.z / 7.5)
				var position_x_in_section = (round(car.global_position.x / 10.0) * -1) + 1
				if position_x_in_section >= 0 and position_x_in_section < ROWS and position_z_in_section > 0 and position_z_in_section < COLS:
					section_array[position_x_in_section][position_z_in_section] += 1.0
					density_array[position_x_in_section][position_z_in_section] += 1.0
	for lane in range(section_array.size()):
		for i in range(section_array[lane].size() - 1):
			
			if section_array[lane][i+1] == 0:
				flow_array[lane][i] += 1.0
	for row in section_array:
		row.fill(0)

func calculate_density():
	var calc_density_array = []
	calc_density_array.resize(ROWS)
	for row in ROWS:
		calc_density_array[row] = []
		calc_density_array[row].resize(COLS)
		calc_density_array[row].fill(0)
	for lane in range(calc_density_array.size()):
		for i in range(calc_density_array[lane].size()):
			calc_density_array[lane][i] = density_array[lane][i] / time_spent
	return calc_density_array

func calculate_flow():
	var calc_flow_array = []
	calc_flow_array.resize(ROWS)
	for row in ROWS:
		calc_flow_array[row] = []
		calc_flow_array[row].resize(COLS)
		calc_flow_array[row].fill(0)
	for lane in range(calc_flow_array.size()):
		for i in range(calc_flow_array[lane].size()):
			calc_flow_array[lane][i] = flow_array[lane][i] / time_spent
	return calc_flow_array

func _update_monitor_data(flow, density):
	var flow_lanes = [flow_lane_1, flow_lane_2, flow_lane_3]
	var density_lanes = [density_lane_1, density_lane_2, density_lane_3]

	for lane in range(flow.size()):
		var lane_flow = flow[lane]
		for value in range(lane_flow.size() - 1):
			flow_lanes[lane].get_child(value).set_value(lane_flow[value])

	for lane in range(density.size()):
		var lane_flow = density[lane]
		for value in range(lane_flow.size() - 1):
			density_lanes[lane].get_child(value).set_value(lane_flow[value])

func _on_update_table_timeout() -> void:
	_update_monitor_data(calculate_flow(), calculate_density())
