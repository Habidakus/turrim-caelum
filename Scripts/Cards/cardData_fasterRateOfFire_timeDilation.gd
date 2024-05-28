extends CardData

var currentBulletsPerMinute : float;
var newBulletsPerMinute : float;
var newTimeDilation : float

func does_change_dps() -> bool:
	return true
func does_change_time_dilation() -> bool:
	return true

func initialize_for_purchase(worth : PlayerWorth):
	currentBulletsPerMinute = 60.0 * worth.bulletsPerSecond
	newBulletsPerMinute = get_delta_increased_rate_of_fire_per_minute(worth) + currentBulletsPerMinute
	worth.bulletsPerSecond = newBulletsPerMinute / 60.0;
	newTimeDilation = get_worse_time_dilation(worth)
	worth.timeDilation = newTimeDilation

func get_description(worth : PlayerWorth) -> String:
	var percent : float = (1000.0 - round(1000.0 * worth.timeDilation / newTimeDilation)) / 10.0	
	var speedText : String = str("Increase from ", int(round(currentBulletsPerMinute)), " to ", int(round(newBulletsPerMinute)), " bullets/minute")
	var timeText : String = str("decrease pilot reflexes by ", percent, "%")
	return str(description, speedText, ", ", timeText)
	
func apply_card(player: Player):
	player.bulletsPerSecond = newBulletsPerMinute / 60.0;
	player.get_parent().timeDilation = newTimeDilation
