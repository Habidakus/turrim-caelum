extends CanvasLayer

@export var card_template_scene: PackedScene
var mapButton = load("res://Scripts/MapButton.gd")

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
	$GameOverStatsPage.hide()
	$Menu.hide()
	$HowToPlay.hide()
	$Credits.hide()
	$MoneyValue.hide()
	$MoneyLabel.hide()
	$HighScoreList.hide()
	$ShowPage_Why.hide()
	$MapSelection.hide()

func select_card(dir: int):
	if dir == 0: # card was clicked on
		activate_card()
	elif dir == 1: # move card selection to the right
		# TODO: Card layout is currently B A C
		if activeCard == $CardA:
			_on_card_a_mouse_exited()
			activeCard = $CardC
		elif activeCard == $CardB:
			_on_card_a_mouse_exited()
			activeCard = $CardA
		elif activeCard == $CardC:
			_on_card_a_mouse_exited()
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

func activate_menu():
	if $Menu/Menu_PlayGame.has_focus():
		_on_menu_play_game_pressed()
	elif $Menu/Menu_HowToGame.has_focus():
		_on_menu_how_to_play_pressed()
	elif $Menu/Menu_Credits.has_focus():
		_on_menu_credits_pressed()
	elif $Menu/Menu_Why.has_focus():
		_on_menu_why_pressed()
	elif $Menu/Menu_HighScore.has_focus():
		_on_menu_highscore_pressed()
	else:
		_on_menu_quit_pressed()
		
func ensure_menu_has_focus():
	if $Menu/Menu_PlayGame.has_focus():
		pass
	elif $Menu/Menu_HowToPlay.has_focus():
		pass
	elif $Menu/Menu_Credits.has_focus():
		pass
	elif $Menu/Menu_Why.has_focus():
		pass
	elif $Menu/Menu_HighScore.has_focus():
		pass
	elif $Menu/Menu_Quit.has_focus():
		pass
	else:
		$Menu/Menu_PlayGame.grab_focus()

func populate_high_score_entry(hscore : String, hmap : String, hname : String):
	var scoreChild = RichTextLabel.new()
	scoreChild.layout_mode = 2
	scoreChild.size_flags_horizontal = 3
	scoreChild.size_flags_vertical = 3
	scoreChild.bbcode_enabled = true
	scoreChild.text = str("[right][font_size=22]", hscore, "[/font_size][/right]")
	scoreChild.fit_content = true
	scoreChild.scroll_active = false
	$HighScoreList/ListContainer.add_child(scoreChild)
	var mapChild = RichTextLabel.new()
	mapChild.layout_mode = 2
	mapChild.size_flags_horizontal = 3
	mapChild.size_flags_vertical = 3
	mapChild.bbcode_enabled = true
	mapChild.text = str("[center][font_size=22]", hmap, "[/font_size][/center]")
	mapChild.fit_content = true
	mapChild.scroll_active = false
	$HighScoreList/ListContainer.add_child(mapChild)
	var nameChild = RichTextLabel.new()
	nameChild.layout_mode = 2
	nameChild.size_flags_horizontal = 3
	nameChild.size_flags_vertical = 3
	nameChild.bbcode_enabled = true
	nameChild.text = str("[left][font_size=22]", hname, "[/font_size][/left]")
	nameChild.fit_content = true
	nameChild.scroll_active = false
	$HighScoreList/ListContainer.add_child(nameChild)
	
func populate_high_score(highScores : Array):
	var children = $HighScoreList/ListContainer.get_children()
	for child in children:
		$HighScoreList/ListContainer.remove_child(child)
	populate_high_score_entry("Score", "Map", "Player")
	for entry in highScores:
		var hscore : int = entry[0]
		var hmap : String = entry[1]
		var hname : String = entry[2]
		populate_high_score_entry(str(hscore), hmap, hname)

func is_event_joypad_select_button(event):
	if event is InputEventJoypadButton:
		var joypadEvent : InputEventJoypadButton = event
		return joypadEvent.is_action_pressed("pause")
	else:
		return false

func _on_menu_play_game_pressed():
	%GameStateMachine.switch_state("Playing_MapSelection")

func _on_menu_play_game_gui_input(event):
	if is_event_joypad_select_button(event):
		%GameStateMachine.switch_state("Playing_MapSelection")

func _on_menu_how_to_play_pressed():
	%GameStateMachine.switch_state("ShowPage_HowToPlay")

func _on_menu_how_to_play_gui_input(event):
	if is_event_joypad_select_button(event):
		%GameStateMachine.switch_state("ShowPage_HowToPlay")

func _on_menu_credits_pressed():
	%GameStateMachine.switch_state("ShowPage_Credits")

func _on_menu_credits_gui_input(event):
	if is_event_joypad_select_button(event):
		%GameStateMachine.switch_state("ShowPage_Credits")

func _on_menu_why_pressed():
	%GameStateMachine.switch_state("ShowPage_Why")

func _on_menu_why_gui_input(event):
	if is_event_joypad_select_button(event):
		%GameStateMachine.switch_state("ShowPage_Why")
	
func _on_menu_highscore_pressed():
	%GameStateMachine.switch_state("ShowPage_HighScore")

func _on_menu_highscore_gui_input(event):
	if is_event_joypad_select_button(event):
		%GameStateMachine.switch_state("ShowPage_HighScore")

func _on_menu_quit_pressed():
	get_tree().quit()
	
func _on_menu_quit_gui_input(event):
	if is_event_joypad_select_button(event):
		get_tree().quit()

func _on_text_meta_clicked(meta):
	OS.shell_open(str(meta))
	
# ----------------- STATE FUNCTIONS -----------------

func show_title():
	$GameTitle.show()

func hide_title():
	$GameTitle.hide()

func show_main_menu():
	$Menu.show()

func hide_main_menu():
	$Menu.hide()

func show_game_over(canContinue : bool):
	$ScoreLabel.show()
	$ScoreValue.show()
	$MoneyValue.hide()
	$MoneyLabel.hide()
	$GameOverStatsPage.show()
	if canContinue:
		$GameOverStatsPage/PressAnyKey.show()
	else:
		$GameOverStatsPage/PressAnyKey.hide()
		get_parent().populate_game_stats($GameOverStatsPage/StatsGrid)

func hide_game_over():
	$ScoreLabel.hide()
	$ScoreValue.hide()
	$GameOverStatsPage.hide()
	var children = $GameOverStatsPage/StatsGrid.get_children()
	for child in children:
		$GameOverStatsPage/StatsGrid.remove_child(child)

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

func show_page_credits():
	$Credits.show()

func hide_page_credits():
	$Credits.hide()
	
func show_page_how_to_play():
	$HowToPlay.show()

func hide_page_how_to_play():
	$HowToPlay.hide()

func show_high_score():
	$HighScoreList.show()

func hide_high_score():
	$HighScoreList.hide()

func show_page_why():
	$ShowPage_Why.show()

func hide_page_why():
	$ShowPage_Why.hide()

func show_map_selection(maps):
	$MapSelection.show()
	for child in $MapSelection/MapButtons.get_children():
		$MapSelection/MapButtons.remove_child(child)
	for map : Map in maps:
		var button = mapButton.new()
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.set_map(map, get_parent())
		$MapSelection/MapButtons.add_child(button)

func hide_map_selection():
	$MapSelection.hide()

func ensure_map_selection_has_focus():
	for button in $MapSelection/MapButtons.get_children():
		if button.has_focus():
			return
	$MapSelection/MapButtons.get_child(0).grab_focus()

func activate_map_selection_with_focus():
	for button in $MapSelection/MapButtons.get_children():
		if button.has_focus():
			button._on_pressed()
