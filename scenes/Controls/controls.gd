class_name SimControls
extends Control


func _ready() -> void:
	_set_default_values_section_1()
	_set_default_values_section_2()
	_set_default_values_section_4()
	pass

func _get_export_range_limits(target_object: Object, property_name: String):
	var properties = target_object.get_property_list()
	for p in properties:
		if p.name == property_name:
			if p.hint == PROPERTY_HINT_RANGE:
				var raw_string = p.hint_string
				var parts = raw_string.split(',')
				var min_val = parts[0].to_float()
				var max_val = parts[1].to_float()
				var step_val = null
				if parts.size() == 3:
					step_val = parts[2].to_float()
				
				return {
					"min": min_val,
					"max": max_val,
					"step": step_val
				}
			else:
				push_error("Variable is not type export_range.")
				return null
	push_error("Variable ", property_name, " was not found.")
	return null

#region Section 1

# Drivers Amount on road

@onready var drivers_amount: HSlider = $"HBoxContainer/Section 1/Margin Container/VBoxContainer/Drivers On Road/HBoxContainer/Drivers Amount"
@onready var drivers_amount_value: Label = $"HBoxContainer/Section 1/Margin Container/VBoxContainer/Drivers On Road/HBoxContainer/Value"

func _on_drivers_amount_value_changed(value: float) -> void:
	drivers_amount_value.text = "%.0f" % value

func _on_drivers_amount_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.drivers_on_road_amount = int(drivers_amount.value)
		Signals.UpdateCars.emit()

# Spawn Delay Time

# DEPRECATED
@onready var spawn_delay_time: HSlider = $"HBoxContainer/Section 1/Margin Container/VBoxContainer/Spawn Delay/HBoxContainer/Spawn Delay Time"
@onready var spawn_delay_time_value: Label = $"HBoxContainer/Section 1/Margin Container/VBoxContainer/Spawn Delay/HBoxContainer/Value"

func _on_spawn_delay_time_value_changed(value: float) -> void:
	spawn_delay_time_value.text = "%.1f" % value


func _on_spawn_delay_time_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.spawn_delay_time = spawn_delay_time.value
		Signals.UpdateTimers.emit()


func _set_default_values_section_1() -> void:
	
	# drivers on road
	var drivers_amount_prop = _get_export_range_limits(Global, "drivers_on_road_amount")
	if drivers_amount_prop:
		drivers_amount.min_value = drivers_amount_prop.min
		drivers_amount.max_value = drivers_amount_prop.max
		if drivers_amount_prop.step:
			drivers_amount.step = drivers_amount_prop.step
	
	drivers_amount.value = Global.drivers_on_road_amount
	_on_drivers_amount_value_changed(Global.drivers_on_road_amount)
	
	pass


#endregion

#endregion

#region Section 2

# Base Velocity

@onready var base_velocity: HSlider = $"HBoxContainer/Section 2/Margin Container/VBoxContainer/Base Velocity/HBoxContainer/Base Velocity"
@onready var base_velocity_value: Label = $"HBoxContainer/Section 2/Margin Container/VBoxContainer/Base Velocity/HBoxContainer/Value"

func _on_base_velocity_value_changed(value: float) -> void:
	base_velocity_value.text = "%.2f" % value

func _on_base_velocity_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.base_velocity = base_velocity.value
		Signals.UpdateCars.emit()

# Base Acceleration
@onready var base_acceleration: HSlider = $"HBoxContainer/Section 2/Margin Container/VBoxContainer/Base Acceleration/HBoxContainer/Base Acceleration"
@onready var base_acceleration_value: Label = $"HBoxContainer/Section 2/Margin Container/VBoxContainer/Base Acceleration/HBoxContainer/Value"

func _on_base_acceleration_value_changed(value: float) -> void:
	base_acceleration_value.text = "%.1f" % value


func _on_base_acceleration_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.base_acceleration = base_acceleration.value
		Signals.UpdateCars.emit()

# Base Deacceleration
@onready var base_deacceleration: HSlider = $"HBoxContainer/Section 2/Margin Container/VBoxContainer/Base Deacceleration/HBoxContainer/Base Deacceleration"
@onready var base_deacceleration_value: Label = $"HBoxContainer/Section 2/Margin Container/VBoxContainer/Base Deacceleration/HBoxContainer/Value"


func _on_base_deacceleration_value_changed(value: float) -> void:
	base_deacceleration_value.text = "%.1f" % value


func _on_base_deacceleration_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.base_deacceleration = base_deacceleration.value
		Signals.UpdateCars.emit()

#Random Threshold Factor

@onready var random_threshold_factor: HSlider = $"HBoxContainer/Section 2/Margin Container/VBoxContainer/Random Threshold/HBoxContainer/Random Threshold Factor"
@onready var random_threshold_factor_value: Label = $"HBoxContainer/Section 2/Margin Container/VBoxContainer/Random Threshold/HBoxContainer/Value"


func _on_random_threshold_factor_value_changed(value: float) -> void:
	random_threshold_factor_value.text = "%.2f" % value


func _on_random_threshold_factor_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.random_threshold_factor = random_threshold_factor.value
		Signals.UpdateThreshold.emit()

func _set_default_values_section_2() -> void:
	
	# base velocity
	var base_velocity_prop = _get_export_range_limits(Global, "base_velocity")
	if base_velocity_prop:
		base_velocity.min_value = base_velocity_prop.min
		base_velocity.max_value = base_velocity_prop.max
		if base_velocity_prop.step:
			base_velocity.step = base_velocity_prop.step
	
	base_velocity.value = Global.base_velocity
	_on_base_velocity_value_changed(Global.base_velocity)
	
	# base acceleration
	var base_accl_prop = _get_export_range_limits(Global, "base_acceleration")
	if base_accl_prop:
		base_acceleration.min_value = base_accl_prop.min
		base_acceleration.max_value = base_accl_prop.max
		if base_accl_prop.step:
			base_acceleration.step = base_accl_prop.step
	base_acceleration.value = Global.base_acceleration
	_on_base_acceleration_value_changed(Global.base_acceleration)
	
	# base decceleration
	var base_deccl_prop = _get_export_range_limits(Global, "base_deacceleration")
	if base_deccl_prop:
		base_deacceleration.min_value = base_deccl_prop.min
		base_deacceleration.max_value = base_deccl_prop.max
		if base_deccl_prop.step:
			base_deacceleration.step = base_deccl_prop.step
	base_deacceleration.value = Global.base_deacceleration
	_on_base_deacceleration_value_changed(Global.base_deacceleration)
	
	# random threshold
	var rand_thres_prop = _get_export_range_limits(Global, "random_threshold_factor")
	if rand_thres_prop:
		random_threshold_factor.min_value = rand_thres_prop.min
		random_threshold_factor.max_value = rand_thres_prop.max
		if rand_thres_prop.step:
			random_threshold_factor.step = rand_thres_prop.step
	random_threshold_factor.value = Global.random_threshold_factor
	_on_random_threshold_factor_value_changed(Global.random_threshold_factor)
	
	pass


#endregion

#region Section 4

# Politeness factor
@onready var politeness_factor: HSlider = $"HBoxContainer/Section 4/ScrollContainer/Margin Container/VBoxContainer/Politeness Factor/HBoxContainer/Politeness Factor"
@onready var politeness_factor_value: Label = $"HBoxContainer/Section 4/ScrollContainer/Margin Container/VBoxContainer/Politeness Factor/HBoxContainer/Value"


func _on_politeness_factor_value_changed(value: float) -> void:
	politeness_factor_value.text = "%.2f" % value


func _on_politeness_factor_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.politeness_factor = politeness_factor.value
		Signals.UpdateCars.emit()

# Decision Threshold
@onready var decision_threshold: HSlider = $"HBoxContainer/Section 4/ScrollContainer/Margin Container/VBoxContainer/Decision Threshold/HBoxContainer/Decision Threshold"
@onready var decision_threshold_value: Label = $"HBoxContainer/Section 4/ScrollContainer/Margin Container/VBoxContainer/Decision Threshold/HBoxContainer/Value"


func _on_decision_threshold_value_changed(value: float) -> void:
	decision_threshold_value.text = "%.2f" % value


func _on_decision_threshold_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.decision_threshold = decision_threshold.value
		Signals.UpdateCars.emit()

# Desired Gap
@onready var desired_gap: HSlider = $"HBoxContainer/Section 4/ScrollContainer/Margin Container/VBoxContainer/Desired Gap/HBoxContainer/Desired Gap"
@onready var desired_gap_value: Label = $"HBoxContainer/Section 4/ScrollContainer/Margin Container/VBoxContainer/Desired Gap/HBoxContainer/Value"


func _on_desired_gap_value_changed(value: float) -> void:
	desired_gap_value.text = "%.0f" % value
	


func _on_desired_gap_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.desired_gap = desired_gap.value
		Signals.UpdateColliders.emit()

# Minimum Gap
@onready var minimum_gap: HSlider = $"HBoxContainer/Section 4/ScrollContainer/Margin Container/VBoxContainer/Minimum Gap/HBoxContainer/Minimum Gap"
@onready var minimum_gap_value: Label = $"HBoxContainer/Section 4/ScrollContainer/Margin Container/VBoxContainer/Minimum Gap/HBoxContainer/Value"


func _on_minimum_gap_value_changed(value: float) -> void:
	minimum_gap_value.text = "%.0f" % value


func _on_minimum_gap_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.minimum_gap = minimum_gap.value
		Signals.UpdateCars.emit()

func _set_default_values_section_4() -> void:
	
	# politeness
	var polit_prop = _get_export_range_limits(Global, "politeness_factor")
	if polit_prop:
		politeness_factor.min_value = polit_prop.min
		politeness_factor.max_value = polit_prop.max
		if polit_prop.step:
			politeness_factor.step = polit_prop.step
	politeness_factor.value = Global.politeness_factor
	_on_politeness_factor_value_changed(Global.politeness_factor)
	
	# decision threshold
	var dec_prop = _get_export_range_limits(Global, "decision_threshold")
	if dec_prop:
		decision_threshold.min_value = dec_prop.min
		decision_threshold.max_value = dec_prop.max
		if dec_prop.step:
			decision_threshold.step = dec_prop.step
	decision_threshold.value = Global.decision_threshold
	_on_decision_threshold_value_changed(Global.decision_threshold)
	
	# desired gap
	var des_gap_prop = _get_export_range_limits(Global, "desired_gap")
	if des_gap_prop:
		desired_gap.min_value = des_gap_prop.min
		desired_gap.max_value = des_gap_prop.max
		if des_gap_prop.step:
			desired_gap.step = des_gap_prop.step
	desired_gap.value = Global.desired_gap
	_on_desired_gap_value_changed(Global.desired_gap)
	
	# minimum gap
	var min_gap_prop = _get_export_range_limits(Global, "minimum_gap")
	if min_gap_prop:
		minimum_gap.min_value = min_gap_prop.min
		minimum_gap.max_value = min_gap_prop.max
		if min_gap_prop.step:
			minimum_gap.step = min_gap_prop.step
	minimum_gap.value = Global.minimum_gap
	_on_minimum_gap_value_changed(Global.minimum_gap)
	
	pass

#endregion

#region Camera

func _on_option_button_item_selected(index: int) -> void:
	Global.selected_camera_preset = index

#endregion


func _on_button_pressed():
	Signals.ResetSimulation.emit()
