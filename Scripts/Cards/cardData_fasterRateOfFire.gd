extends CardData

var currentBulletsPerMinute : float;
var newBulletsPerMinute : float;

func initialize_for_purchase(worth : PlayerWorth):
	currentBulletsPerMinute = 60.0 * worth.bulletsPerSecond
	newBulletsPerMinute = get_delta_increased_rate_of_fire_per_minute(worth) + currentBulletsPerMinute
	worth.bulletsPerSecond = newBulletsPerMinute / 60.0;

func get_description(_worth : PlayerWorth) -> String:
	return str(description, "Increase from ", int(round(currentBulletsPerMinute)), " to ", int(round(newBulletsPerMinute)), " bullets/minute")
	
func apply_card(player: Player):
	player.bulletsPerSecond = newBulletsPerMinute / 60.0;
