extends Node2D

var player = load("res://player.tscn")
# Called when the node enters the scene tree for the first time.
var p1
var p2
var prioTimeLooser  = {"p1":0,"p2":0} 
var priority = {"p1":1, "p2":1}
func _ready() -> void:

	p1 = player.instantiate()
	add_child(p1)
	p1.action.connect(_player_action)

	p2 = player.instantiate()
	p2.player = "p2"
	add_child(p2)
	p2.action.connect(_player_action)


func _process(delta: float) -> void:
	print(priority)
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

func _player_action(player, action):
	if action == "back":
		priority[player] = -1
	if action == "forward" and priority[other(player)] <= 0:
		priority[player] = 1
	if action == "lunge":
		prioTimeLooser[player] = 0.5 if prioTimeLooser[player] != 0 else prioTimeLooser[player]
	if action == "attack":
		prioTimeLooser[player] = 0.5 if prioTimeLooser[player] != 0 else prioTimeLooser[player]
