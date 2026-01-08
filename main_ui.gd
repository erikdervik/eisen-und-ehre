extends Control

var is_active = true
signal start
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_active:
		#Engine.time_scale = 0
		get_tree().paused = true
		visible = true
	else:
		if Input.is_action_just_pressed("escape"):
			is_active = true


func _on_play_button_down() -> void:
	is_active = false
	visible = false
	emit_signal("start")
	
