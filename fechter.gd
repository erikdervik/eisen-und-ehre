extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var state = "NONE" #parry, attack, walkFront walkBack, lunge

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("p1_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("p1_right") and is_on_floor():
		velocity.x = SPEED
	elif Input.is_action_just_pressed("p1_left") and is_on_floor():
		velocity.x = -SPEED
	else:
		velocity.x = 0
	
	move_and_slide()
