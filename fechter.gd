extends CharacterBody2D
const SPEED = 3000.0
const JUMP_VELOCITY = -400.0

const CAN_PARRY = ["IDLE","FORWARD", "BACK"]
const CAN_ATTACK = ["IDLE","FORWARD", "BACK"]
const CAN_LUNGE = ["IDLE","FORWARD"]
const CAN_JUMP = ["IDLE","FORWARD", "BACK"]
const CAN_FOWARD = ["IDLE","FORWARD", "BACK"]
const CAN_BACK = ["IDLE","FORWARD", "BACK"]

var state = "IDLE"
var parryTime = 0
func _physics_process(delta: float) -> void:
	print(state)
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("p1_jump") and is_on_floor() and state in CAN_JUMP:
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("p1_attack") and is_on_floor() and state in CAN_ATTACK:
		state = "ATTACK"
		#CHANGE ANIMATION
		#SPAWN HITBOX after N frames
	if Input.is_action_just_pressed("p1_lunge") and is_on_floor() and state in CAN_LUNGE:
		state = "LUNGE"
		#CHANGE ANIMATION
		#CATAPULT RIGHT
		#SPAWN HITBOX after N frames
	if Input.is_action_just_pressed("p1_parry") and is_on_floor() and state in CAN_PARRY:
		state = "PARRY"
		#change animation
		parryTime = 3

	if Input.is_action_pressed("p1_right") and is_on_floor() and state in CAN_FOWARD:
		state = "FORWARD"
		velocity.x = SPEED * delta
	elif Input.is_action_pressed("p1_left") and is_on_floor() and state in CAN_BACK:
		state = "BACK"
		velocity.x = -SPEED * delta
	elif is_on_floor():
		state = "IDLE"
		velocity.x = 0
		
	
	
	move_and_slide()
