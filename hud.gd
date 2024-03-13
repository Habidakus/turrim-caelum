extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$GameTitle.show()
	$ScoreLabel.hide()
	$ScoreValue.hide()
	$GameOver.hide()
	$PressAnyKey.hide()
	$MoneyValue.hide()
	$MoneyLabel.hide()

func spend_points():
	$GameTitle.hide()
	$ScoreLabel.show()
	$ScoreValue.show()
	$GameOver.hide()
	$PressAnyKey.hide()
	$MoneyValue.hide()
	$MoneyLabel.hide()
	
func game_over():
	$GameTitle.hide()
	$ScoreLabel.show()
	$ScoreValue.show()
	$GameOver.show()
	$PressAnyKey.hide()
	$MoneyValue.hide()
	$MoneyLabel.hide()

func start_game():
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
	if dollars == 1:
		$MoneyLabel.show()
		$MoneyValue.show()
	$MoneyValue.text = str(dollars)
	
func set_score(score : int):
	$ScoreValue.text = str(score)
