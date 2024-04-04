extends CardData

var increaseToBulletDamage : float
var decreaseToBulletRange : float

func does_change_range() -> bool:
	return true
func does_change_dps() -> bool:
	return true

func initialize_for_purchase(worth : PlayerWorth):
	increaseToBulletDamage = get_damage_we_will_add(worth)
	worth.bulletDamage += increaseToBulletDamage
	decreaseToBulletRange = get_decrease_to_bullet_range(worth)
	worth.bulletRange -= decreaseToBulletRange
	
func get_description(worth : PlayerWorth) -> String:
	var newDamage: float = worth.bulletDamage + increaseToBulletDamage
	var newRange : float =  worth.bulletRange - decreaseToBulletRange
	var damageText : String = str("Bullet damage increased from ", int(round(worth.bulletDamage)), " to ", int(round(newDamage)))
	var rangeText : String = str("range decreased from ", int(round(worth.bulletRange)), " to ", int(round(newRange)))
	return str(description, damageText, ", ", rangeText)

func apply_card(player: Player):
	player.bullet_damage += increaseToBulletDamage
	player.bullet_range -= decreaseToBulletRange
