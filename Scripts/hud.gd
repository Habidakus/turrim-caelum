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
	$GameTitle.hide()
	$ScoreLabel.hide()
	$ScoreValue.hide()
	$GameOver.hide()
	$PressAnyKey.hide()
	$MoneyValue.hide()
	$MoneyLabel.hide()

func select_card(dir: int):
	if dir == 0: # card was clicked on
		if activeCard != null:
			%HUD.activate_card(activeCard)
		else:
			print_debug("Clicked when no card active!")
	elif dir == 1: # move card selection to the right
		# TODO: Card layout is currently B A C
		if activeCard == $CardA:
			%HUD._on_card_a_mouse_exited()
			activeCard = $CardC
		elif activeCard == $CardB:
			%HUD._on_card_a_mouse_exited()
			activeCard = $CardA
		elif activeCard == $CardC:
			%HUD._on_card_a_mouse_exited()
			activeCard = $CardB
		else:
			activeCard = $CardB
		var cardTemplate = find_card_template(activeCard)
		if cardTemplate != null:
			cardTemplate.mouse_hover(true)
	elif dir == -1: # move card selection to the left
		# TODO: Card layout is currently B A C
		if activeCard == $CardA:
			_on_card_a_mouse_exited()
			activeCard = $CardB
		elif activeCard == $CardB:
			_on_card_a_mouse_exited()
			activeCard = $CardC
		elif activeCard == $CardC:
			_on_card_a_mouse_exited()
			activeCard = $CardA
		else:
			activeCard = $CardC
		var cardTemplate = find_card_template(activeCard)
		if cardTemplate != null:
			cardTemplate.mouse_hover(true)
	else:
		print_debug("Illegal card selection value: ", dir)

func init_card(card, cardData: CardData, player : Player):
	var cardTemplate = find_card_template(card)
	if cardTemplate != null:
		cardTemplate.init(cardData, player)

func spend_points(cardA : CardData, cardB : CardData, cardC : CardData, player : Player):
	init_card($CardA, cardA, player)
	init_card($CardB, cardB, player)
	init_card($CardC, cardC, player)

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
		activate_card()

func activate_card():
	if activeCard != null:
		var cardTemplate = find_card_template(activeCard)
		if cardTemplate != null:
			cardTemplate.apply()
			cardTemplate.mouse_hover(false)
			activeCard = null

# ----------------- STATE FUNCTIONS -----------------

func show_title():
	$GameTitle.show()

func hide_title():
	$GameTitle.hide()

func show_main_menu():
	$PressAnyKey.show()

func hide_main_menu():
	$PressAnyKey.hide()

func show_game_over():
	$ScoreLabel.show()
	$ScoreValue.show()
	$GameOver.show()

func hide_game_over():
	$ScoreLabel.hide()
	$ScoreValue.hide()
	$GameOver.hide()

func show_game_card_selection():
	$CardA.show()
	$CardB.show()
	$CardC.show()

func hide_game_card_selection():
	$CardA.hide()
	$CardB.hide()
	$CardC.hide()

func show_game_action():
	$ScoreLabel.show()
	$ScoreValue.show()
	
func hide_game_action():
	$ScoreLabel.hide()
	$ScoreValue.hide()
