extends CanvasLayer

@export var card_template_scene: PackedScene

var activeCard = null
	
func find_card_viewport(card) -> SubViewport:
	if card == null:
		return null
	return card.get_child(0)

func find_card_template(card) -> Control:
	if card == null:
		return null
	var card_viewport = card.get_child(0)
	if card_viewport == null:
		return null
	return card_viewport.get_child(0)

func setup_card(card : TextureRect):
	var viewport = SubViewport.new()
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.size = Vector2(250, 350)
	viewport.add_child(card_template_scene.instantiate())
	card.size = Vector2(250,350)
	card.add_child(viewport)
	card.texture = viewport.get_texture()

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_card($CardA)
	setup_card($CardB)
	setup_card($CardC)
	$CardA.hide()
	$CardB.hide()
	$CardC.hide()
	$GameTitle.show()
	$ScoreLabel.hide()
	$ScoreValue.hide()
	$GameOver.hide()
	$PressAnyKey.hide()
	$MoneyValue.hide()
	$MoneyLabel.hide()

func init_card(card, cardData: CardData, player : Player):
	var cardTemplate = find_card_template(card)
	if cardTemplate != null:
		cardTemplate.init(cardData, player)

func spend_points(cardA : CardData, cardB : CardData, cardC : CardData, player : Player):
	init_card($CardA, cardA, player)
	init_card($CardB, cardB, player)
	init_card($CardC, cardC, player)
	$CardA.show()
	$CardB.show()
	$CardC.show()
	$GameTitle.hide()
	$ScoreLabel.show()
	$ScoreValue.show()
	$GameOver.hide()
	$PressAnyKey.hide()

func stop_shopping():
	$CardA.hide()
	$CardB.hide()
	$CardC.hide()
	$GameTitle.hide()
	$ScoreLabel.show()
	$ScoreValue.show()
	$GameOver.hide()
	$PressAnyKey.hide()
	
func game_over():
	$CardA.hide()
	$CardB.hide()
	$CardC.hide()
	$GameTitle.hide()
	$ScoreLabel.show()
	$ScoreValue.show()
	$GameOver.show()
	$PressAnyKey.hide()
	$MoneyValue.hide()
	$MoneyLabel.hide()

func start_game():
	$CardA.hide()
	$CardB.hide()
	$CardC.hide()
	$GameTitle.hide()
	$ScoreLabel.show()
	$ScoreValue.show()
	$GameOver.hide()
	$PressAnyKey.hide()
	$MoneyValue.hide()
	$MoneyLabel.hide()

func show_restart():
	$PressAnyKey.show()

func set_money(dollars : int):
	if dollars > 0:
		$MoneyLabel.show()
		$MoneyValue.show()
	else:
		$MoneyLabel.hide()
		$MoneyValue.hide()
	$MoneyValue.text = str(dollars)
	
func set_score(score : int):
	$ScoreValue.text = str(score)

func _on_card_a_mouse_entered():
	var cardRect = Rect2(Vector2(), Vector2(250, 350))
	var mouse_pos = get_viewport().get_mouse_position()
	var nextActiveCard = null
	if cardRect.has_point(mouse_pos - $CardA.position):
		nextActiveCard = $CardA
	elif cardRect.has_point(mouse_pos - $CardB.position):
		nextActiveCard = $CardB
	elif cardRect.has_point(mouse_pos - $CardC.position):
		nextActiveCard = $CardC
	if nextActiveCard != activeCard:
		activeCard = nextActiveCard
		var cardTemplate = find_card_template(activeCard)
		if cardTemplate != null:
			cardTemplate.mouse_hover(true)

func _on_card_a_mouse_exited():
	if activeCard != null:
		var cardTemplate = find_card_template(activeCard)
		if cardTemplate != null:
			cardTemplate.mouse_hover(false)
		activeCard = null

func _on_card_a_gui_input(event):
	if event is InputEventMouseButton:
		if activeCard != null:
			var cardTemplate = find_card_template(activeCard)
			if cardTemplate != null:
				cardTemplate.apply()
			activeCard = null
