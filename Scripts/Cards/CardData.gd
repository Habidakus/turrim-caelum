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

# --------------------- library functions ----------------------------------

func get_damage_we_will_add(player: Player, cardData: CardData) -> float:
	var multiple = cardData.get_multiple(player, cardData)
	var straight_add = 10.0 * multiple * multiple
	var scale_existing = player.bullet_damage * (sqrt(multiple) - 1.0)
	return max(straight_add, scale_existing)

func get_damage_we_will_remove(player: Player, cardData: CardData) -> float:
	var multiple = sqrt(cardData.get_multiple(player, cardData))
	var straight_remove = 10.0 * multiple * multiple
	var scale_existing = player.bullet_damage * (sqrt(multiple) - 1.0)
	return min(straight_remove, scale_existing)

func get_delta_increased_rate_of_fire_per_minute(cardData: CardData) -> float:
	return (60 * (cardData.boonMultiple - 1))

func get_delta_decreased_rate_of_fire_per_minute(cardData: CardData) -> float:
	return (60 * (sqrt(cardData.boonMultiple) - 1))

func get_bullet_speed_we_will_add(player: Player, cardData: CardData) -> float:
	return (get_multiple(player, cardData) - 1.0) * player.bullet_speed
func get_bullet_speed_we_will_remove(player: Player, cardData: CardData) -> float:
	return (sqrt(get_multiple(player, cardData)) - 1.0) * player.bullet_speed
	
func get_increase_to_bullet_range(player: Player, cardData: CardData) -> float:
	return (get_multiple(player, cardData) - 1.0) * player.bullet_range
func get_decrease_to_bullet_range(player: Player, cardData: CardData) -> float:
	return (sqrt(get_multiple(player, cardData)) - 1.0) * player.bullet_range
