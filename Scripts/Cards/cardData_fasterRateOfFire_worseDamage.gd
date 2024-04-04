extends CardData

var currentBulletsPerMinute : float;
var newBulletsPerMinute : float;
var decreaseToBulletDamage : float;

func does_change_dps() -> bool:
	return true

func initialize_for_purchase(worth : PlayerWorth):
	currentBulletsPerMinute = 60.0 * worth.bulletsPerSecond
	newBulletsPerMinute = get_delta_increased_rate_of_fire_per_minute(worth) + currentBulletsPerMinute
	worth.bulletsPerSecond = newBulletsPerMinute / 60.0;
	decreaseToBulletDamage = get_damage_we_will_remove(worth)
	worth.bulletDamage -= decreaseToBulletDamage

func get_description(worth : PlayerWorth) -> String:
	var speedText : String = str("Increase from ", int(round(currentBulletsPerMinute)), " to ", int(round(newBulletsPerMinute)), " bullets/minute")
	var newDamage: float = worth.bulletDamage - decreaseToBulletDamage
	var damageText : String = str("bullet damage decreased from ", int(round(worth.bulletDamage)), " to ", int(round(newDamage)))
	return str(description, speedText, ", ", damageText)
	
func apply_card(player: Player):
	player.bulletsPerSecond = newBulletsPerMinute / 60.0;
	player.bullet_damage -= decreaseToBulletDamage
