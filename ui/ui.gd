extends CanvasLayer

## プレイヤーのHPを表示するプログレスバー
@onready var hp_bar = $HPBar
## HPを数値で表示するためのラベル要素（HPBarの子ノード）
@onready var hp_label = $HPBar/Label
## レベルラベル
@onready var level_label = $EXPBar/LevelLabel
## ゲームオーバー時に表示される画面
@onready var game_over_screen = $GameOverScreen
## 所持スキルアイコンのコンテナ
@onready var skill_icon_container = $SkillIconContainer

## スキルアイコンのテクスチャ辞書
var icon_textures = {
	"shot": preload("res://assets/icons/shot_icon.png"),
	"explosion": preload("res://assets/icons/explosion_icon.png"),
	"sword": preload("res://assets/icons/sword_icon.png")
}

## レベルアップ選択時のシグナル
signal upgrade_selected(upgrade_id: String)

## レベルアップ画面の参照
@onready var level_up_panel = $LevelUpPanel
@onready var labels = [
	$LevelUpPanel/HBoxContainer/Card1/Label,
	$LevelUpPanel/HBoxContainer/Card2/Label,
	$LevelUpPanel/HBoxContainer/Card3/Label
]

## 出現しうるアップグレードのリスト
const UPGRADES = [
	{"id": "max_hp_up", "name": "最大HP +20"},
	{"id": "heal_full", "name": "HP 全回復"},
	{"id": "speed_up", "name": "移動速度UP"},
	{"id": "sword", "name": "剣の強化"},
	{"id": "shot", "name": "ショット魔法"},
	{"id": "explosion", "name": "爆発魔法"}
]

## 現在提示されている選択肢
var current_options = []

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

## スキルアイコンの表示を更新する関数
func update_skill_icons(skills: Array):
	# 古いアイコンを全削除
	for child in skill_icon_container.get_children():
		child.queue_free()
		
	# 新しいリストに基づいてアイコンを追加
	for skill in skills:
		if icon_textures.has(skill.id):
			var tex_rect = TextureRect.new()
			tex_rect.texture = icon_textures[skill.id]
			tex_rect.custom_minimum_size = Vector2(64, 64)
			tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			
			var lbl = Label.new()
			lbl.text = "Lv" + str(skill.level)
			lbl.add_theme_font_size_override("font_size", 16)
			lbl.add_theme_color_override("font_outline_color", Color.BLACK)
			lbl.add_theme_constant_override("outline_size", 4)
			
			# 右下揃えの設定
			lbl.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_KEEP_SIZE)
			lbl.grow_horizontal = Control.GROW_DIRECTION_BEGIN
			lbl.grow_vertical = Control.GROW_DIRECTION_BEGIN
			
			tex_rect.add_child(lbl)
			skill_icon_container.add_child(tex_rect)

## リトライボタンが押された時の処理
func _on_retry_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

## レベルアップ画面を表示する
func show_level_up_screen(active_skills: Array):
	current_options.clear()
	var available = []
	
	for u in UPGRADES:
		var is_max_level = false
		for s in active_skills:
			if s.id == u.id and s.level >= 3:
				is_max_level = true
				break
		if not is_max_level:
			available.append(u)
			
	available.shuffle()
	
	for i in range(3):
		if available.size() > 0:
			var opt = available.pop_back()
			current_options.append(opt)
			labels[i].text = opt.name
			
	level_up_panel.visible = true
	get_tree().paused = true

func _on_card_1_pressed():
	_select_upgrade(0)

func _on_card_2_pressed():
	_select_upgrade(1)

func _on_card_3_pressed():
	_select_upgrade(2)

func _on_skip_button_pressed():
	level_up_panel.visible = false
	get_tree().paused = false

func _select_upgrade(index: int):
	if index < current_options.size():
		emit_signal("upgrade_selected", current_options[index].id)
	level_up_panel.visible = false
	get_tree().paused = false
