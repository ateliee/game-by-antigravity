extends Node2D

## スポーンさせる敵のシーン
@export var enemy_scene: PackedScene
## プレイヤーノードへの参照
@onready var player = $Player
## UIノードへの参照
@onready var ui = $UI

## メインシーン初期化時に呼ばれる関数
func _ready():
	# プレイヤーのシグナルをUIに接続する
	player.hp_changed.connect(ui.update_hp)
	player.died.connect(_on_player_died)
	player.exp_changed.connect(ui.update_exp)
	player.level_up.connect(ui.update_level)
	
	# UIの初期化を行う
	ui.update_hp(player.hp, player.max_hp)
	ui.update_exp(player.exp, player.max_exp)
	ui.update_level(player.level)

## プレイヤーが死亡した際に呼ばれるイベント処理
func _on_player_died():
	# ゲームオーバー画面を表示する
	ui.show_game_over()

## 敵スポーン用タイマーのタイムアウト時に呼ばれる処理
func _on_spawn_timer_timeout():
	if not enemy_scene:
		return
		
	# 敵のインスタンスを生成する
	var enemy = enemy_scene.instantiate()
	
	# プレイヤーを中心とした円周上のランダムな位置にスポーンさせる
	var angle = randf() * TAU
	# 画面外になるように大きな距離を設定する
	var distance = 800
	var spawn_pos = player.position + Vector2(cos(angle), sin(angle)) * distance
	
	# 生成した敵の位置とプレイヤーへの参照を設定する
	enemy.position = spawn_pos
	enemy.player = player
	add_child(enemy)
