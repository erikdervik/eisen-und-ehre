extends Area2D

signal hit(player, parries)
var lifetime = 0
var player = ""
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime < 0:
		self.queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("p1"):
		if player != "p1":
			emit_signal("hit","p1", area.is_in_group("parries"))
	if area.is_in_group("p2"):
		if player != "p2":
			emit_signal("hit","p2", area.is_in_group("parries"))
