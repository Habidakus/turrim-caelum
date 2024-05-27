extends CardData

var newTimeDilation : float

func does_change_time_dilation() -> bool:
	return true

func initialize_for_purchase(worth : PlayerWorth):
	newTimeDilation = get_new_time_dilation(worth)
	worth.timeDilation = newTimeDilation
	
func get_description(worth : PlayerWorth) -> String:
	var percent : float = (round(1000.0 * worth.timeDilation / newTimeDilation) - 1000.0) / 10.0
	return str(description, "Increase pilot reflexes by ", percent, "%")

func apply_card(player: Player):
	player.get_parent().timeDilation = newTimeDilation
