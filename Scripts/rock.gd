extends Area2D

func _ready():
	var rng = RandomNumberGenerator.new()
	$Polygon2D.color.h += rng.randf_range(-0.025, 0.025)
	$Polygon2D.color.s += rng.randf_range(-0.025, 0.025)
	$Polygon2D.color.v += rng.randf_range(-0.025, 0.025)

func _on_area_entered(area : Area2D):
	if area.is_in_group("mob"):
		area.on_hit(2000)
