extends CardData

func is_curse() -> bool:
	# Although slotted with the curses, this curse is a GNDN curse;
	# so don't give it the red background, and test to see if it's player valid
	return false;

func initialize_for_purchase(worth : PlayerWorth):
	worth.tchotchkeCount += 1
	
func apply_card(player: Player):
	player.tchotchke = true
