extends Node2D

var player = load("res://player.tscn")
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@export var hit_sounds: Array[AudioStream] = []
@export var parry_sounds: Array[AudioStream] = []
@onready var silas_player: AudioStreamPlayer = $silasPlayer
@export var en_garde: AudioStream
@export var pret: AudioStream
@export var allez: AudioStream
@export var attaque_a_gauche_touche: AudioStream
@export var attaque_simultane: AudioStream
@export var attaque_a_droite_touche: AudioStream
@export var halte: AudioStream


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
const startpos1 = Vector2(-72,265)
const startpos2 = Vector2(72,265)
const people = ["Silas","Laura","Lotte","Imke","Luis","Jan","Mirko","Erik","Justus","Charlotte","Miguel","Felix","Alex","Niklas","Ben","Emil","Hilde","Rico"]
func play_silas_sound(sound, language="fr"):
	if typeof(sound) == TYPE_ARRAY:
		audio_player.stream = sound.pick_random()
	else:
		audio_player.stream = sound
	audio_player.play()

func play_sound(sound):
	if typeof(sound) == TYPE_ARRAY:
		audio_player.stream = sound.pick_random()
	else:
		audio_player.stream = sound
	audio_player.play()

func _on_hit(p, parries, sound):
	if parries == false:
		if sound:
			play_sound(hit_sounds)

		hasHit[p] = true
		if end_timer == 0.0:
			freeze_priority = true
			end_timer = 1.0
	else:
		if sound:
			play_sound(parry_sounds)

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

func eval_priority():
	if priority["p1"] > priority["p2"]:
		return "p1"
	elif priority["p2"] > priority["p1"]:
		return "p2"
	else:
		return "eq"

func _ready() -> void:
	p1 = player.instantiate()
	add_child(p1)
	p1.action.connect(_player_action)
	p2 = player.instantiate()
	p2.player = "p2"
	add_child(p2)
	p2.action.connect(_player_action)
	p1.position = startpos1
	p2.position = startpos2

func modifyScoreboard(win):
	scores[win] += 1
	$scoreP1.text = str(scores["p1"])
	$scoreP2.text = str(scores["p2"])

func reset():
	p1.position = startpos1
	p2.position = startpos2
	hasHit = {"p1":false,"p2":false}
	prioTimeLooser  = {"p1":0,"p2":0}
	priority = {"p1":1, "p2":1}
	freeze_priority = false
	end_timer = 0.0

func process_judge():
	if judge_state in ["p1", "", "p2", "eq"]:
		judge_state = eval_priority()
	if judge_state == "STOP":
		$judge_speak.text = "STOP"
	elif judge_state =="p1point":
		$judge_speak.text = "p1point"
	elif judge_state =="p2point":
		$judge_speak.text = "p2point"
	elif $judge_speak.text in ["STOP","p1point","p2point"]:
		$judge_speak.text = ""

	match judge_state:
		"start":
			pass
		"p1":
			$judge.play("Angriffsrecht(links)")
		"p2":
			$judge.play("Angriffsrecht(rechts)")
		"STOP":
			$judge.play("halt")
		"p1point":
			$judge.play("Treffer(rechts)")
		"p2point":
			$judge.play("Treffer(links)")
		"simultanpoint":
			$judge.play("Simultanees")
		"eq":
			$judge.play("Idle")
	# Set label
	# change Animations

func start():
	judge_state="start"
	$judge.play("StellungFertigLos")
	get_tree().create_timer(1.0,true,false,true).timeout.connect(func(): play_silas_sound(en_garde))
	get_tree().create_timer(1.0,true,false,true).timeout.connect(func(): $judge_speak.text =  "en Garde")
	get_tree().create_timer(2.0,true,false,true).timeout.connect(func(): $judge_speak.text = "pret")
	get_tree().create_timer(2.0,true,false,true).timeout.connect(func(): play_silas_sound(pret))
	get_tree().create_timer(3.0,true,false,true).timeout.connect(func(): $judge_speak.text = "allez!")
	get_tree().create_timer(3.0,true,false,true).timeout.connect(func(): play_silas_sound(allez))
	get_tree().create_timer(4.0,true,false,true).timeout.connect(func(): get_tree().paused = false)
	get_tree().create_timer(6.0,true,false,true).timeout.connect(func(): $judge_speak.text = "")
	get_tree().create_timer(6.0,true,false,true).timeout.connect(func(): judge_state = "eq")

func _process(delta: float) -> void:
	process_judge()
	end_timer -= delta if end_timer > 0.0 else 0.0
	if end_timer < 0.0:
		judge_state = "STOP"
		winner = eval_winner()
		#Engine.time_scale = 0
		get_tree().paused = true
		get_tree().create_timer(1.0,true,false,true).timeout.connect(func(): judge_state = winner+"point")
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
	if get_tree().paused == false:
		if action == "back":
			priority[p] = -1
		if action == "forward" and priority[other(p)] <= 0:
			priority[p] = 1
		if action == "lunge":
			prioTimeLooser[p] = 0.5 if prioTimeLooser[p] == 0.0 else prioTimeLooser[p]
		if action == "attack":
			prioTimeLooser[p] = 0.5 if prioTimeLooser[p] == 0.0 else prioTimeLooser[p]

func _on_main_ui_start() -> void:
	#$p1Name.text = people.pick_random()
	$p1Name.text = "Ben"
	$p2Name.text = people.pick_random()
	
	if $p1Name.text == "Ben":
		p1.isBen = 1
	else:
		p1.isBen = 0

	if $p2Name.text == "Ben":
		p2.isBen = 1
	else:
		p2.isBen = 0

	reset()
	print("yay")
	scores = {"p1":0,"p2":0, "simultan" : 0}
	$scoreP1.text = str(scores["p1"])
	$scoreP2.text = str(scores["p2"])
	start()
