extends CharacterBody3D

@export_group("Movement fields")
@export var max_speed = 12
@export var max_jumps = 2
var jump_count = 0

@export_group("Physics fields")
@export var gravity = -40
@export var acceleration = 70
@export var friction = 60
@export var air_friction = 10
@export var jump_impulse = 20.0
@export var rot_speed = 25
var input_vector
var direction
var snap_vector = Vector3.ZERO

#State flags
var jumpPressed = false
var jumpReleased = false

#Node references
@onready var pivot = $Pivot
@onready var armature = $Pivot/Armature
@onready var anim_tree = $AnimationTree

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	_process_Inputs()
	_update_State()
	_process_Movement(delta)
	# Animation
	anim_tree.set("parameters/BlendSpace1D/blend_position", velocity.length() / max_speed)

func _process_Inputs():
	input_vector = get_input_vector()
	direction = get_direction(input_vector)
	jumpPressed = true if Input.is_action_just_pressed("jump") else false
	jumpReleased = true if (Input.is_action_just_released("jump") and velocity.y > jump_impulse / 2) else false
	
func _update_State():
	pass
	
func _process_Movement(delta):
	if direction != Vector3.ZERO: apply_movement(input_vector, direction, delta)
	else: apply_friction(delta)
	apply_gravity(delta)
	if (jumpPressed or jumpReleased) and jump_count < max_jumps: jump()
	move_and_slide()
	if is_on_floor(): jump_count = 0
	
func get_input_vector():
	var input_vector = Vector3.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	return input_vector.normalized() if input_vector.length() > 1 else input_vector

func get_direction(input_vector):
	var direction = (input_vector.x * transform.basis.x) + (input_vector.z * transform.basis.z)
	return direction
	
func apply_movement(input_vector, direction, delta):
	velocity.x = velocity.move_toward(direction * max_speed, acceleration * delta).x
	velocity.z = velocity.move_toward(direction * max_speed, acceleration * delta).z
	pivot.rotation.y = lerp_angle(pivot.rotation.y, atan2(-input_vector.x, -input_vector.z), rot_speed * delta)

func apply_friction(delta):
	if is_on_floor():
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
	else:
		velocity.x = velocity.move_toward(direction * max_speed, air_friction * delta).x
		velocity.z = velocity.move_toward(direction * max_speed, air_friction * delta).z
		
func apply_gravity(delta):
	velocity.y += gravity * delta
	velocity.y = clamp(velocity.y, gravity, jump_impulse)
	
func jump():
	
	if (jumpReleased): velocity.y = jump_impulse / 2
	elif (jumpPressed): 
		velocity.y = jump_impulse
		jump_count+= 1
