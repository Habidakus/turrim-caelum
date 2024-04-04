extends CardData

var increaseToBulletRange : float

func does_change_range() -> bool:
	return true

func initialize_for_purchase(worth : PlayerWorth):
	increaseToBulletRange = get_increase_to_bullet_range(worth)
	worth.bulletRange += increaseToBulletRange

func get_description(worth : PlayerWorth) -> String:
	var newRange : float = increaseToBulletRange + worth.bulletRange
	return str(description, "Bullet range increase from ", int(round(worth.bulletRange)), " to ", int(round(newRange)))
	
func apply_card(player: Player):
	player.bullet_range += increaseToBulletRange
