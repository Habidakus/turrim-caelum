extends CardData

var increaseToBulletDamage : float

func initialize_for_purchase(worth : PlayerWorth):
	increaseToBulletDamage = get_damage_we_will_add(worth)
	worth.bulletDamage += increaseToBulletDamage
	
func get_description(worth : PlayerWorth) -> String:
	var newDamage: float = worth.bulletDamage + increaseToBulletDamage
	return str(description, "Bullet damage increased from ", int(round(worth.bulletDamage)), " to ", int(round(newDamage)))

func apply_card(player: Player):
	player.bullet_damage += increaseToBulletDamage
