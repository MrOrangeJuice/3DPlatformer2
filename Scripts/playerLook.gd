extends SpringArm3D

@export_group("Camera look")
@export var mouse_sensitivity = .1
@export var controller_sensitivity = 3

@export_group("Zoom fields")
@export var zoom_increment = .1
@export var max_camera_distance = 10
@export var min_camera_distance = 2
@export var current_zoom = 6

#Node references
@onready var parent = get_parent()
@onready var spring_arm = self


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spring_arm.spring_length = clamp(current_zoom, min_camera_distance, max_camera_distance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	apply_controller_rotation()
	spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-75), deg_to_rad(75))
	spring_arm.spring_length = current_zoom


func _unhandled_input(event):
	if event.is_action_pressed("click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event.is_action_pressed("toggle_mouse_captured"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		parent.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		spring_arm.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-75), deg_to_rad(75))
		
	if event.is_action_released("camera_zoom_in"):
		current_zoom -= zoom_increment
	elif event.is_action_released("camera_zoom_out"):
		current_zoom += zoom_increment
		
	current_zoom = clamp(current_zoom, min_camera_distance, max_camera_distance)
		
			
func apply_controller_rotation():
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axis_vector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	if InputEventJoypadMotion:
		parent.rotate_y(deg_to_rad(-axis_vector.x) * controller_sensitivity)
		spring_arm.rotate_x(deg_to_rad(-axis_vector.y) * controller_sensitivity)
