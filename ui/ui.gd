extends CanvasLayer

## プレイヤーのHPを表示するプログレスバー
@onready var hp_bar = $HPBar
## HPを数値で表示するためのラベル要素（HPBarの子ノード）
@onready var hp_label = $HPBar/Label
## レベルラベル
@onready var level_label = $EXPBar/LevelLabel
## ゲームオーバー時に表示される画面
@onready var game_over_screen = $GameOverScreen

## HPの表示を更新する関数
## @param hp: 現在のHP
## @param max_hp: 最大HP
func update_hp(hp: int, max_hp: int):
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	# 「現在のHP/最大HP」の形式でラベルのテキストを更新
	hp_label.text = str(hp) + "/" + str(max_hp)

## EXPの表示を更新する関数
## @param current_exp: 現在の経験値
## @param max_exp: 次のレベルに必要な経験値
func update_exp(current_exp: int, max_exp: int):
	$EXPBar.max_value = max_exp
	$EXPBar.value = current_exp

## レベルの表示を更新する関数
## @param level: 現在のレベル
func update_level(level: int):
	level_label.text = "Lv. " + str(level)

## ゲームオーバー画面を表示する関数
func show_game_over():
	game_over_screen.visible = true
	# ツリーを一時停止状態にしてゲームの進行を止める
	get_tree().paused = true

## リトライボタンが押された時の処理
func _on_retry_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
