extends Resource

class_name CardData

enum BoonType { 
	playerSpeed = 1, 
	bulletSpeed = 2,
	fireRate = 3,
	bulletLife = 4,
	moreDamage = 5,
	autospend = 6,
	revealSooner = 7,
	curseAdvanceMonsters = 8,
}

@export_group("Text")
@export var cardName : String
@export_multiline var description : String

@export_group("boon")
@export var boonType : BoonType
@export var boonMultiple : float

func is_curse() -> bool:
	return false
	
func is_possible(_player: Player, _cardData: CardData) -> bool:
	return true

func initialize_for_purchase(_player: Player, _cardData: CardData):
	pass

func get_description(_player: Player, _cardData: CardData) -> String:
	return description

func get_multiple(_player: Player, _cardData: CardData) -> float:
	return boonMultiple

func apply_card(_player: Player):
	print_debug("CARD ", cardName, " failed to implement apply_card")
