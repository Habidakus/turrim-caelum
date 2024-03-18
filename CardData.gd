extends Resource

class_name CardData

enum BoonType { 
	playerSpeed, 
	bulletSpeed,
	fireRate,
	bulletLife,
	moreDamage,
	autospend
}

@export_group("Text")
@export var cardName : String
@export_multiline var description : String

@export_group("boon")
@export var boonType : BoonType
@export var boonMultiple : float

func is_possible(_player: Player, _cardData: CardData) -> bool:
	return true

func initialize_for_purchase(_player: Player, _cardData: CardData):
	pass

func get_description(_player: Player, _cardData: CardData) -> String:
	return description

func get_multiple(_player: Player, _cardData: CardData) -> float:
	return boonMultiple
