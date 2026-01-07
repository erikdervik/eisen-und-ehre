extends Control

var is_active = true
signal start
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print("PROCESS")
	if is_active:
		Engine.time_scale = 0
		visible = true
	else:
		if Input.is_action_just_pressed("escape"):
			is_active = true


func _on_play_button_down() -> void:
	#CALLE DIE STARTFUNKTION ANSTATT EINFACH LOSZUMACHEN
	Engine.time_scale = 1
	print("YOY")
	is_active = false
	visible = false
	emit_signal("start")
	
