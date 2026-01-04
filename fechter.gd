extends CharacterBody2D
const SPEED = 9000.0
const JUMP_VELOCITY = -300.0




const CAN_PARRY = ["IDLE","FORWARD", "BACK"]
const CAN_ATTACK = ["IDLE","FORWARD", "BACK"]
const CAN_LUNGE = ["IDLE","FORWARD"]
const CAN_JUMP = ["IDLE","FORWARD", "BACK"]
const CAN_FOWARD = ["IDLE","FORWARD", "BACK"]
const CAN_BACK = ["IDLE","FORWARD", "BACK"]
const CAN_IDLE = ["IDLE","FORWARD", "BACK", "JUMP"]
const CAN_FOWARD_ATTACK = ["FORWARD"]
const CAN_BACK_ATTACK = ["BACK"]

var lungeVelocity = 0
var state = "IDLE"
var parryTime = 0
var lungeTime = 0
var attackTime = 0
var d = 0
var groundPoundTime = 0

func _physics_process(delta: float) -> void:
	velocity.x = lungeVelocity if lungeVelocity > 0 else velocity.x
	lungeVelocity = max(0,lungeVelocity - (delta * 9))

	parryTime = max(parryTime - delta, -3)
	lungeTime = max(lungeTime - delta, -3)
	attackTime = max(attackTime - delta, -3)
	groundPoundTime = max(groundPoundTime - delta, -3)
	
	if state == "LUNGE" and lungeTime < 0 or state == "PARRY" and parryTime < 0 or state == "ATTACK" and attackTime < 0:
		state = "IDLE"
		$AnimatedSprite2D.play("idle")
		
	d += delta
	if d>0.2:
		print(state)
		d=0
		
	if is_on_floor():
		if Input.is_action_just_pressed("p1_jump") and state in CAN_JUMP:
			state = "JUMP"
			velocity.y = JUMP_VELOCITY
	
		if Input.is_action_just_pressed("p1_attack") and state in CAN_ATTACK and attackTime < -2:

			if state in CAN_FOWARD_ATTACK:	
				$AnimatedSprite2D.play("hit n walk")
			elif state in CAN_BACK_ATTACK:
				$AnimatedSprite2D.play("hit n back")
			elif state in CAN_ATTACK:
				velocity = Vector2.ZERO
				$AnimatedSprite2D.play("hit n stand")
			state = "ATTACK"
			attackTime = 1
		if Input.is_action_just_pressed("p1_lunge") and state in CAN_LUNGE and lungeTime < -2:
			state = "LUNGE"
			velocity = Vector2.ZERO
			lungeVelocity = 150
			lungeTime = 0.85
			$AnimatedSprite2D.play("lunge")
		if Input.is_action_just_pressed("p1_parry") and state in CAN_PARRY and parryTime < -2:
			state = "PARRY"
			parryTime = 0.5
			$AnimatedSprite2D.play("idle")
		if Input.is_action_pressed("p1_right") and state in CAN_FOWARD:
			state = "FORWARD"
			$AnimatedSprite2D.play("walk")
			velocity.x = SPEED * delta
		elif Input.is_action_pressed("p1_left")  and state in CAN_BACK:
			state = "BACK"
			velocity.x = -SPEED * delta
			$AnimatedSprite2D.play("backwards")
		elif state in CAN_IDLE and velocity.y >= 0:
			state = "IDLE"
			velocity.x = 0
			$AnimatedSprite2D.play("idle")
	else:
		groundPoundTime = 1
		velocity += get_gravity() * delta
	move_and_slide()
