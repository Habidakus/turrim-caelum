extends CardData

var increaseToBulletSpeed : float

func does_change_player_or_bullet_speed() -> bool:
	return true

func initialize_for_purchase(worth : PlayerWorth):
	increaseToBulletSpeed = get_bullet_speed_we_will_add(worth)
	worth.bulletSpeed += increaseToBulletSpeed
	
func get_description(worth : PlayerWorth) -> String:
	var newSpeed : float = worth.bulletSpeed + increaseToBulletSpeed
	return str(description, "Bullet speed increase from ", int(round(worth.bulletSpeed)), " to ", int(round(newSpeed)))

func apply_card(player: Player):
	player.bullet_speed += increaseToBulletSpeed
