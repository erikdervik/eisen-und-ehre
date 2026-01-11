extends CharacterBody2D
var hit = load("res://hit.tscn")

const SPEED = 9000.0
const JUMP_VELOCITY = -200.0

const CAN_PARRY = ["IDLE","FORWARD", "BACK"]
const CAN_ATTACK = ["IDLE","FORWARD", "BACK"]
const CAN_LUNGE = ["IDLE","FORWARD"]
const CAN_JUMP = ["IDLE","FORWARD", "BACK"]
const CAN_FOWARD = ["IDLE","FORWARD", "BACK"]
const CAN_BACK = ["IDLE","FORWARD", "BACK"]
const CAN_IDLE = ["IDLE","FORWARD", "BACK", "JUMP"]
const CAN_FOWARD_ATTACK = ["FORWARD"]
const CAN_BACK_ATTACK = ["BACK"]

var player = "p1"
var lungeVelocity = 0.0
var state = "IDLE"
var parryTime = 0
var lungeTime = 0
var attackTime = 0
var d = 0
var groundPoundTime = 0
var direction = 0
var hitTime = 0.0
var parriesTimer = 0.0
var isBen = 0
var noInput = false
signal action(player, action)

var allstar := preload("res://player_allstar.tres")
var uhlman := preload("res://player_uhlmann.tres")

func spawn_hitbox(offset,lifetime):
	var hitbox = hit.instantiate()
	add_child(hitbox)
	hitbox.position.x += offset
	hitbox.lifetime = lifetime
	hitbox.player = player
	hitbox.hit.connect(get_tree().current_scene._on_hit)

func play_anim(s):
	$AnimatedSprite2D.play(s)


func _ready() -> void:
	self.get_child(0).add_to_group(player)
	direction = 1 if player == "p1" else -1
	scale.x = scale.x if player == "p1" else -scale.x
	$AnimatedSprite2D.sprite_frames = uhlman if player == "p1" else allstar

func _physics_process(delta: float) -> void:		
	parriesTimer = parriesTimer-delta if parriesTimer > 0.0 else 0.0
	if parriesTimer > 0 and not self.is_in_group("parries"):
		self.get_child(0).add_to_group("parries")
	else:
		self.get_child(0).remove_from_group("parries")

	hitTime = hitTime-delta if hitTime > 0.0 else 0.0
	if hitTime < 0.0:
		spawn_hitbox(0,0.35)
		hitTime = 0.0
	
	lungeVelocity = lungeVelocity - (delta * 600+PI) if lungeVelocity != 0.0 else 0.0
	lungeVelocity = 0.0 if lungeVelocity < -20 else lungeVelocity
		
	velocity.x = direction * lungeVelocity if lungeVelocity != 0.0 else velocity.x
	
	parryTime = max(parryTime - (delta*(1+isBen)), -3)
	lungeTime = max(lungeTime - (delta*(1+isBen)), -3)
	attackTime = max(attackTime - (delta*(1+isBen)), -3)
	groundPoundTime = max(groundPoundTime - delta, 0)
	
	
	if state == "LUNGE" and lungeTime < 0 or state == "PARRY" and parryTime < 0 or state == "ATTACK" and attackTime < 0:
		state = "IDLE"
		$AnimatedSprite2D.play("idle")
	
	if is_on_floor() and not noInput:
		if Input.is_action_just_pressed(player + "_jump") and state in CAN_JUMP:
			state = "JUMP"
			velocity.y = JUMP_VELOCITY + isBen * -150
	
		if Input.is_action_just_pressed(player + "_attack") and state in CAN_ATTACK and attackTime < -2:
			hitTime = 0.25
			if state in CAN_FOWARD_ATTACK:
				$AnimatedSprite2D.play("hit n walk")
			elif state in CAN_BACK_ATTACK:
				$AnimatedSprite2D.play("hit n back")
			elif state in CAN_ATTACK:
				velocity = Vector2.ZERO
				$AnimatedSprite2D.play("hit n stand")
			state = "ATTACK"
			attackTime = 1
			emit_signal("action",player,"attack") # Loose Priority if Attack finished
		if Input.is_action_just_pressed(player + "_lunge") and state in CAN_LUNGE and lungeTime < -2:
			hitTime = 0.25
			state = "LUNGE"
			velocity = Vector2.ZERO
			lungeVelocity = 300 + 50 * groundPoundTime + 200 * isBen
			lungeTime = 0.85
			$AnimatedSprite2D.play("lunge")
			emit_signal("action",player,"lunge") # loose priority after lunge is finished

		if Input.is_action_just_pressed(player + "_parry") and state in CAN_PARRY and parryTime < -2:
			state = "PARRY"
			parryTime = 1
			parriesTimer = 1.5 + isBen
			$AnimatedSprite2D.play("parade")
			
			
		
		if (player == "p1" and Input.is_action_pressed("p1_right") or player == "p2" and Input.is_action_pressed("p2_left")) and state in CAN_FOWARD:
			state = "FORWARD"
			
			if player == "p1" and Input.is_action_pressed("p1_sprint") or player == "p2" and Input.is_action_pressed("p2_sprint"):
				$AnimatedSprite2D.play("sprint")
				print("SPRINT")
				velocity.x = direction * SPEED * delta * 1.5 * (1+(0.7*isBen))
			else:
				$AnimatedSprite2D.play("walk")
				velocity.x = direction * SPEED * delta * (1+(0.7*isBen))
			emit_signal("action",player,"forward") # gain priority a little bit
		elif (player == "p1" and Input.is_action_pressed("p1_left") or player == "p2" and Input.is_action_pressed("p2_right")) and state in CAN_BACK:
			state = "BACK"
			velocity.x = -1 * direction * SPEED * delta  * (1+(0.7*isBen))
			$AnimatedSprite2D.play("backwards")
			emit_signal("action",player,"back") # loose priority completly
		elif state in CAN_IDLE and velocity.y >= 0:
			state = "IDLE"
			velocity.x = 0
			$AnimatedSprite2D.play("idle")
	else:
		groundPoundTime = 1
		velocity += get_gravity() * delta
	move_and_slide()
