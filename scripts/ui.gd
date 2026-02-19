extends CanvasLayer

@onready var hp_bar = $HPBar
@onready var game_over_screen = $GameOverScreen

func update_hp(hp, max_hp):
	hp_bar.max_value = max_hp
	hp_bar.value = hp

func show_game_over():
	game_over_screen.visible = true
	# Pause the game? Usually handled by main or here.
	# Let's pause the tree.
	get_tree().paused = true

func _on_retry_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
