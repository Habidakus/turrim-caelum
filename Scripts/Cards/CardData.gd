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
	curseAdvanceSpawnRate = 9,
	curseTchotchke = 10,
}

@export_group("Text")
@export var cardName : String
@export_multiline var description : String

@export_group("boon")
@export var boonType : BoonType
@export var boonMultiple : float

func is_curse() -> bool:
	return false

func initialize_for_purchase(_worth : PlayerWorth):
	print_debug("CARD ", cardName, " failed to implement initialize_for_purchase")

func get_description(_worth : PlayerWorth) -> String:
	return description

func apply_card(_player: Player):
	print_debug("CARD ", cardName, " failed to implement apply_card")

# --------------------- library functions ----------------------------------

func get_damage_we_will_add(worth : PlayerWorth) -> float:
	var multSqrt = sqrt(boonMultiple)
	var straight_add = 10.0 * boonMultiple * multSqrt
	var scale_existing = worth.bulletDamage * (multSqrt - 1.0)
	return max(straight_add, scale_existing)

func get_damage_we_will_remove(worth : PlayerWorth) -> float:
	var multSqrt = sqrt(boonMultiple)
	var straight_remove = 10.0 * boonMultiple * multSqrt
	var scale_existing = worth.bulletDamage * (sqrt(multSqrt) - 1.0)
	return min(straight_remove, scale_existing)

func get_delta_increased_rate_of_fire_per_minute(_worth : PlayerWorth) -> float:
	return (60 * (boonMultiple - 1))

func get_delta_decreased_rate_of_fire_per_minute(_worth : PlayerWorth) -> float:
	return (60 * (sqrt(boonMultiple) - 1))

func get_bullet_speed_we_will_add(worth : PlayerWorth) -> float:
	return (boonMultiple - 1.0) * worth.bulletSpeed
func get_bullet_speed_we_will_remove(worth : PlayerWorth) -> float:
	return (sqrt(boonMultiple) - 1.0) * worth.bulletSpeed
	
func get_increase_to_bullet_range(worth : PlayerWorth) -> float:
	return (boonMultiple - 1.0) * worth.bulletRange
func get_decrease_to_bullet_range(worth : PlayerWorth) -> float:
	return (sqrt(boonMultiple) - 1.0) * worth.bulletRange
