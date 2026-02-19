extends Node2D

@export var enemy_scene: PackedScene
@onready var player = $Player
@onready var ui = $UI

func _ready():
	# Connect player signals to UI
	player.hp_changed.connect(ui.update_hp.bind(player.max_hp))
	player.died.connect(_on_player_died)
	
	# Initialize UI
	ui.update_hp(player.hp, player.max_hp)

func _on_player_died():
	ui.show_game_over()

func _on_spawn_timer_timeout():
	if not enemy_scene:
		return
		
	var enemy = enemy_scene.instantiate()
	
	# Choose a random location on Path2D or just random outside screen.
	# Simple approach: Random angle and distance
	var angle = randf() * TAU
	var distance = 800 # Radius larger than screen
	var spawn_pos = player.position + Vector2(cos(angle), sin(angle)) * distance
	
	enemy.position = spawn_pos
	enemy.player = player
	add_child(enemy)
