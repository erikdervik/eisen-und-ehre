extends Node2D

var player = load("res://player.tscn")

# Called when the node enters the scene tree for the first time.
var judge_state = ""

var p1
var p2
var prioTimeLooser  = {"p1":0,"p2":0}
var priority = {"p1":1, "p2":1}
var freeze_priority = false
var end_timer = 0.0
var hasHit = {"p1":false,"p2":false}
var scores = {"p1":0,"p2":0, "simultan" : 0}
var winner
var startpos1 = Vector2(-200,300)
var startpos2 = Vector2(200,300)

func _on_hit(p, parries):
	if parries == false:
		hasHit[p] = true
		if end_timer == 0.0:
			freeze_priority = true
			end_timer = 1.0
	else:
		pass


func eval_winner():
	if hasHit["p1"] and not hasHit["p2"]:
		return "p1"
	elif hasHit["p2"] and not hasHit["p1"]:#
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
	scores[win] += 1
	$scoreP1.text = str(scores["p1"])
	$scoreP2.text = str(scores["p2"])
	pass
func reset():
	p1.position = startpos1
	p2.position = startpos2
	hasHit = {"p1":false,"p2":false}
	prioTimeLooser  = {"p1":0,"p2":0}
	priority = {"p1":1, "p2":1}
	freeze_priority = false
	end_timer = 0.0


func process_judge():
	pass
	# Set label
	# change Animations

func start():
	get_tree().create_timer(1.0,true,false,true).timeout.connect(func(): pass)
	get_tree().create_timer(2.0,true,false,true).timeout.connect(func(): pass)
	get_tree().create_timer(3.0,true,false,true).timeout.connect(func(): pass)
	get_tree().create_timer(3.0,true,false,true).timeout.connect(func(): Engine.time_scale = 1)

func _process(delta: float) -> void:
	print(judge_state)
	end_timer -= delta if end_timer > 0.0 else 0.0
	if end_timer < 0.0:
		judge_state = "STOP"
		winner = eval_winner()
		Engine.time_scale = 0
		get_tree().create_timer(1.0,true,false,true).timeout.connect(func(): judge_state = winner)
		get_tree().create_timer(4.0,true,false,true).timeout.connect(func(): modifyScoreboard(winner))
		get_tree().create_timer(5.0,true,false,true).timeout.connect(reset)
		get_tree().create_timer(7.0,true,false,true).timeout.connect(start)
	
		end_timer = 0.0
		

	if not freeze_priority:
		if prioTimeLooser["p1"] < 0:
			priority["p1"] = -1
			priority["p2"] = 0 if priority["p2"] == -1 else priority["p2"]
			prioTimeLooser["p1"] = 0
		elif prioTimeLooser["p1"] > 0:
			prioTimeLooser["p1"] -= delta
		if prioTimeLooser["p2"] < 0:
			priority["p2"] = -1
			priority["p1"] = 0 if priority["p1"] == -1 else priority["p1"]
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
		prioTimeLooser[p] = 0.5 if prioTimeLooser[p] == 0.0 else prioTimeLooser[p]
	if action == "attack":
		prioTimeLooser[p] = 0.5 if prioTimeLooser[p] == 0.0 else prioTimeLooser[p]
