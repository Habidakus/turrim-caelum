extends Control

var player = null
var mouseOver : bool = false
var cardData : CardData = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(_cardData : CardData, _player):
	player = _player
	cardData = _cardData
	$Label.text = cardData.cardName
	$Description.text = cardData.description

func mouse_hover(is_hovering : bool):
	if is_hovering:
		$Background.color = Color.LIGHT_BLUE
	else:
		$Background.color = Color.WHITE

func apply():
	player.apply_card(cardData)
