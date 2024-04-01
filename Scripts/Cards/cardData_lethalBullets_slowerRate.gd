extends CardData

var increaseToBulletDamage : float
var currentBulletRateOfFirePerMinute : float
var decreasedBulletRateOfFirePerMinute : float

func initialize_for_purchase(worth : PlayerWorth):
	increaseToBulletDamage = get_damage_we_will_add(worth)
	worth.bulletDamage += increaseToBulletDamage
	currentBulletRateOfFirePerMinute = worth.bulletsPerSecond * 60.0
	decreasedBulletRateOfFirePerMinute = currentBulletRateOfFirePerMinute - get_delta_decreased_rate_of_fire_per_minute(worth)
	worth.bulletsPerSecond = decreasedBulletRateOfFirePerMinute / 60.0

func get_description(worth : PlayerWorth) -> String:
	var newDamage: float = worth.bulletDamage + increaseToBulletDamage
	var damageText : String = str("Bullet damage increased from ", int(round(worth.bulletDamage)), " to ", int(round(newDamage)))
	var slowText : String = str("Rate of fire decreased from ", int(round(currentBulletRateOfFirePerMinute)) , " to ", int(round(decreasedBulletRateOfFirePerMinute)))
	return str(description, damageText, ", ", slowText)

func apply_card(player: Player):
	player.bullet_damage += increaseToBulletDamage
	player.bulletsPerSecond = decreasedBulletRateOfFirePerMinute / 60.0
