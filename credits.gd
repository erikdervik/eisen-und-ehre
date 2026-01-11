extends Control

var is_active = false

signal start

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_active:
		get_tree().paused = true
		visible = true
	

func _on_play_button_down() -> void:
	is_active = false
	visible = false
	emit_signal("start")
	
