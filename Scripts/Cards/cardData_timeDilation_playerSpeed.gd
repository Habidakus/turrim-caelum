extends CardData

var newTimeDilation : float
var decreaseToPlayerSpeed : float

func does_change_time_dilation() -> bool:
	return true
func does_change_player_or_bullet_speed() -> bool:
	return true

func initialize_for_purchase(worth : PlayerWorth):
	newTimeDilation = get_new_time_dilation(worth)
	worth.timeDilation = newTimeDilation
	decreaseToPlayerSpeed = get_decrease_to_player_speed(worth)
	worth.shipSpeed -= decreaseToPlayerSpeed
	
func get_description(worth : PlayerWorth) -> String:
	var percent : float = (round(1000.0 * worth.timeDilation / newTimeDilation) - 1000.0) / 10.0
	var newSpeed : float =  worth.shipSpeed - decreaseToPlayerSpeed
	var timeText : String = str("Increase pilot reflexes by ", percent, "%")
	var speedText : String = str("ship speed decreased from ", int(round(worth.shipSpeed)), " to ", int(round(newSpeed)))
	return str(description, timeText, ", ", speedText)

func apply_card(player: Player):
	player.get_parent().timeDilation = newTimeDilation
	player.speed -= decreaseToPlayerSpeed
