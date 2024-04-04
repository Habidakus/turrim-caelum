extends CardData

var increaseToBulletDamage : float
var decreaseToPlayerSpeed : float

func does_change_player_or_bullet_speed() -> bool:
	return true
func does_change_dps() -> bool:
	return true

func initialize_for_purchase(worth : PlayerWorth):
	increaseToBulletDamage = get_damage_we_will_add(worth)
	worth.bulletDamage += increaseToBulletDamage
	decreaseToPlayerSpeed = get_decrease_to_player_speed(worth)
	worth.shipSpeed -= decreaseToPlayerSpeed
	
func get_description(worth : PlayerWorth) -> String:
	var newDamage: float = worth.bulletDamage + increaseToBulletDamage
	var newSpeed : float =  worth.shipSpeed - decreaseToPlayerSpeed
	var damageText : String = str("Bullet damage increased from ", int(round(worth.bulletDamage)), " to ", int(round(newDamage)))
	var speedText : String = str("ship speed decreased from ", int(round(worth.shipSpeed)), " to ", int(round(newSpeed)))
	return str(description, damageText, ", ", speedText)

func apply_card(player: Player):
	player.bullet_damage += increaseToBulletDamage
	player.speed -= decreaseToPlayerSpeed
