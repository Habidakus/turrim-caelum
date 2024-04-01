extends CardData

func is_curse() -> bool:
	return true;

func initialize_for_purchase(_worth : PlayerWorth):
	pass
	
func apply_card(player: Player):
	player.get_parent().advance_id(boonMultiple)
