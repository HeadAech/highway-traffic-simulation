extends Camera3D

@export var lerp_time: float = 4.0

@export var move_speed = 5.0
@export var mouse_sensitivity = 500.0
@export var acceleration = 50.0

var look_angle = Vector2.ZERO
var cam_velocity = Vector3.ZERO

var positions : Dictionary[Global.CameraPreset, Vector3] = {
	#Global.CameraPreset.FREEROAM : Vector3(23.4, 23.15, -50),
	Global.CameraPreset.SIDEVIEW : Vector3(-65, 40, 270),
	Global.CameraPreset.WITH_TRAFFIC : Vector3(1.26, 12.5, 25),
	Global.CameraPreset.COUNTER_TRAFFIC : Vector3(1.26, 12.5, 350),
	Global.CameraPreset.TOP_VIEW : Vector3(1.26, 75, 270)
}

var rotations : Dictionary[Global.CameraPreset, Vector3] = {
	#Global.CameraPreset.FREEROAM : Vector3(-20.5, 90, 0),
	Global.CameraPreset.SIDEVIEW : Vector3(-20.5, -90, 0),
	Global.CameraPreset.WITH_TRAFFIC : Vector3(-32, 180, 0),
	Global.CameraPreset.COUNTER_TRAFFIC : Vector3(-32, 0, 0),
	Global.CameraPreset.TOP_VIEW : Vector3(-90, -90, 0)
}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	position = lerp(position, positions[Global.selected_camera_preset], delta * lerp_time)
	
	rotation.x = lerp_angle(rotation.x, deg_to_rad(rotations[Global.selected_camera_preset].x), delta * lerp_time)
	rotation.y = lerp_angle(rotation.y, deg_to_rad(rotations[Global.selected_camera_preset].y), delta * lerp_time)
	rotation.z = lerp_angle(rotation.z, deg_to_rad(rotations[Global.selected_camera_preset].z), delta * lerp_time)
