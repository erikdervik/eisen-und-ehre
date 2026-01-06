extends Node2D

var player = load("res://player.tscn")
# Called when the node enters the scene tree for the first time.
var p1
var p2
var prioTimeLooser  = {"p1":0,"p2":0}
var priority = {"p1":1, "p2":1}
var freeze_priority = false
var end_timer = 0.0
var hasHit = {"p1":false,"p2":false}
var winner

func _on_hit(p, parries):
	if parries == false:
		hasHit[p] = true
		if end_timer == 0.0:
			freeze_priority = true
			end_timer = 1.0
	else:
		print("PARRIED") #PLAY SOUND
	print(p,parries)

func eval_winner():
	if hasHit["p1"] and not hasHit["p2"]:
		return "p1"
	elif hasHit["p2"] and not hasHit["p1"]:
		return "p2"
	elif priority["p1"] > priority["p2"]:
		return "p1"
	elif priority["p1"] < priority["p2"]:
		return "p2"
	else:
		return "simultan"

func _ready() -> void:
	p1 = player.instantiate()
	add_child(p1)
	p1.action.connect(_player_action)
	p2 = player.instantiate()
	p2.player = "p2"
	add_child(p2)
	p2.action.connect(_player_action)

func modifyScoreboard(win):
	pass
func reset():
	pass

func _process(delta: float) -> void:
	end_timer -= delta if end_timer > 0.0 else 0.0
	#CHANGE TIMESCALE WEN END TIMER > 0 ????
	if end_timer < 0.0:
		winner = eval_winner()
		print(winner)
		reset()
		modifyScoreboard(winner)
		end_timer = 0.0
		
	if not freeze_priority:
		if prioTimeLooser["p1"] < 0:
			priority["p1"] = -1
			priority["p2"] = 0
			prioTimeLooser["p1"] = 0
		elif prioTimeLooser["p1"] > 0:
			prioTimeLooser["p1"] -= delta
		if prioTimeLooser["p2"] < 0:
			priority["p2"] = -1
			priority["p1"] = 0
			prioTimeLooser["p2"] = 0
		elif prioTimeLooser["p2"] > 0:
			prioTimeLooser["p2"] -= delta

func other(s : String):
	match s:
		"p1":
			return "p2"
		"p2":
			return "p1"
		_: return ""

func _player_action(p, action):
	if action == "back":
		priority[p] = -1
	if action == "forward" and priority[other(p)] <= 0:
		priority[p] = 1
	if action == "lunge":
		prioTimeLooser[p] = 0.5 if prioTimeLooser[p] != 0 else prioTimeLooser[p]
	if action == "attack":
		prioTimeLooser[p] = 0.5 if prioTimeLooser[p] != 0 else prioTimeLooser[p]
