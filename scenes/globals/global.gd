extends Node


enum CameraPreset {
	SIDEVIEW, WITH_TRAFFIC, COUNTER_TRAFFIC, TOP_VIEW #, FREEROAM
}

@export_group("Camera Preset")
@export var selected_camera_preset: CameraPreset = CameraPreset.SIDEVIEW

## Section Editor - Editor stuff
@export_group("Section 1 - Editor")
@export_range(0,200,1) var drivers_on_road_amount : int = 50

@export_subgroup("Lane Setup")
@export var lane1_weight: float = 31.3
@export var lane2_weight: float = 31.3
@export var lane3_weight: float = 31.3
@export var lane4_weight: float = 6.1

## Section 2 - Basic Follow Stuff
@export_group("Section 2 - Basic Movement")
@export_range(15.00,66.66) var base_velocity : float = 33.33  		
@export_range(0.5,3.0,0.1) var base_acceleration : float = 1.5
@export_range(0.5,3.0,0.1) var base_deacceleration : float = 1.5
@export_range(0.0, 1.0, 0.01) var random_threshold_factor : float = 0.7

## Section 3 - Driver Types Stuff
#@export_group("Section 3 - Driver Types")
enum DriverType { CALM, MEDIOCRE, AGGRESSIVE }


## Section 4 Merging stuff
@export_group("Section 4 Merging")
@export_range(0,0.9,0.01) var politeness_factor : float = 0.5 
@export_range(0,0.9,0.01) var decision_threshold : float = 0.5

@export_range(10.0,30.0,0.1) var desired_gap : float = 20.0
@export_range(10.0,30.0,0.1) var minimum_gap : float = 10.0
@export_range(1.0,3.0,1.0) var desired_headway : float = 2.0
