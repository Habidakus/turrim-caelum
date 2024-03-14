extends Resource

class_name CardData

enum BoonType { playerSpeed, bulletSpeed, fireRate, bulletLife, moreDamage }

@export_group("Text")
@export var cardName : String
@export_multiline var description : String

@export_group("boon")
@export var boonType : BoonType
@export var boonMultiple : float
