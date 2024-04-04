extends CardData

var increaseToBulletRange : float
var decreaseToBulletSpeed : float

func does_change_player_or_bullet_speed() -> bool:
	return true
func does_change_range() -> bool:
	return true

func initialize_for_purchase(worth : PlayerWorth):
	increaseToBulletRange = get_increase_to_bullet_range(worth)
	worth.bulletRange += increaseToBulletRange
	decreaseToBulletSpeed = get_bullet_speed_we_will_remove(worth)
	worth.bulletSpeed -= decreaseToBulletSpeed
	
func get_description(worth : PlayerWorth) -> String:
	var newSpeed : float = worth.bulletSpeed - decreaseToBulletSpeed
	var newRange : float = worth.bulletRange + increaseToBulletRange
	var rangeText : String = str("Bullet range increase from ", int(round(worth.bulletRange)), " to ", int(round(newRange)))
	var speedText : String = str("speed reduced from ", int(round(worth.bulletSpeed)), " to ", int(round(newSpeed)))
	return str(description, rangeText, ", ", speedText)

func apply_card(player: Player):
	player.bullet_range += increaseToBulletRange
	player.bullet_speed -= decreaseToBulletSpeed
