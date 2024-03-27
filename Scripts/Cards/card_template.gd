extends Control

var player : Player = null
var mouseOver : bool = false
var cardData : CardData = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(_cardData : CardData, _player : Player):
	player = _player
	cardData = _cardData
	$Label.text = cardData.cardName
	$Description.text = cardData.get_description(_player, _cardData)

func mouse_hover(is_hovering : bool):
	if is_hovering:
		if cardData.is_curse():
			$Background.color = Color.LIGHT_PINK
		else:
			$Background.color = Color.LIGHT_BLUE
	else:
		$Background.color = Color.WHITE

func apply():
	cardData.apply_card(player)
	player.get_parent().player_has_spent()

