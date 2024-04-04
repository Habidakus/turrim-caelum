extends CardData

var increaseToBulletSpeed : float
var decreaseToBulletDamage : float

func does_change_player_or_bullet_speed() -> bool:
	return true
func does_change_dps() -> bool:
	return true

func initialize_for_purchase(worth : PlayerWorth):
	increaseToBulletSpeed = get_bullet_speed_we_will_add(worth)
	worth.bulletSpeed += increaseToBulletSpeed
	decreaseToBulletDamage = get_damage_we_will_remove(worth)
	worth.bulletDamage -= decreaseToBulletDamage

func get_description(worth : PlayerWorth) -> String:
	var newSpeed : float = worth.bulletSpeed + increaseToBulletSpeed
	var newDamage: float = worth.bulletDamage - decreaseToBulletDamage
	var speedText : String = str("Bullet speed increase from ", int(round(worth.bulletSpeed)), " to ", int(round(newSpeed)))
	var damageText : String = str("bullet damage decreased from ", int(round(worth.bulletDamage)), " to ", int(round(newDamage)))
	return str(description, speedText, ", ", damageText)

func apply_card(player: Player):
	player.bullet_speed += increaseToBulletSpeed
	player.bullet_damage -= decreaseToBulletDamage
