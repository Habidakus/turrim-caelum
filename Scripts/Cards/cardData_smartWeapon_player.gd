extends CardData

func does_change_player_charges() -> bool:
	return true
	
func initialize_for_purchase(worth : PlayerWorth):
	worth.smartWeaponCount += 1
	
func apply_card(player: Player):
	player.activate_smart_weapon(false) # false will explode those closest to player
