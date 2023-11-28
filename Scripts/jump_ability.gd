extends CharacterAbility

@export var max_jumps = 2
var jump_count = 0

@export var jump_impulse = 20.0

func _physics_process(delta):
	if parent_character.is_on_floor(): jump_count = 0

func _activate_ability(action_info: String = ''):
	if (jump_count < max_jumps): _jump(action_info)
		
func _jump(jump_type: String):
	if jump_type == "jumpReleased": parent_character.velocity.y = jump_impulse / 2
	elif jump_type == "jumpPressed": 
		parent_character.velocity.y = jump_impulse
		jump_count+= 1
