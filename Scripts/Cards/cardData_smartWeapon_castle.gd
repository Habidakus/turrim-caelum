extends CardData

func does_change_player_charges() -> bool:
	return true
func does_reference_map() -> bool:
	return true
func does_requires_castle() -> bool:
	return true

func initialize_for_purchase(worth : PlayerWorth):
	worth.smartWeaponCount += 1
	
func apply_card(player: Player):
	player.activate_smart_weapon(true) # True will explose those closest to castle
