extends Area2D

func _ready():
	var rng = RandomNumberGenerator.new()
	var polygon : Polygon2D
	match rng.randi() % 3:
		0: polygon = $VisualShape1
		1: polygon = $VisualShape2
		2: polygon = $VisualShape3
	polygon.color.h += rng.randf_range(-0.025, 0.025)
	polygon.color.s += rng.randf_range(-0.025, 0.025)
	polygon.color.v += rng.randf_range(-0.025, 0.025)
	polygon.visible = true

func _on_area_entered(area : Area2D):
	if area.is_in_group("mob"):
		area.on_hit(2000)
