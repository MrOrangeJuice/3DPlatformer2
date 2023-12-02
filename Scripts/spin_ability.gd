extends CharacterAbility

@export var spin_speed = 25
@export var spin_radius = 1
@export var spin_time = 0.5
@export var spin_damage = 1
var spin_count = 0
var isSpinning = false
var canSpin = true

# Node references
@onready var model = $spinModel
@onready var collisionShape = $spinModel/CollisionShape3D
@onready var mesh = $spinModel/MeshInstance3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if spin_count <= spin_time && isSpinning:
		spin_count += delta
		
	if spin_count >= spin_time:
		spin_count = 0
		isSpinning = false
		model.process_mode = Node.PROCESS_MODE_DISABLED
		model.hide()
		
	if isSpinning == false && parent_character.is_on_floor():
		canSpin = true

func _activate_ability(action_info: String = ''):
	if (isSpinning == false && canSpin):
		spin_count = 0
		isSpinning = true
		canSpin = false
		model.process_mode = Node.PROCESS_MODE_INHERIT
		model.show()
	elif isSpinning:
		isSpinning = false
		model.process_mode = Node.PROCESS_MODE_DISABLED
		model.hide()
