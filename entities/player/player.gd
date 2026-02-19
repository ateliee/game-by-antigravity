extends CharacterBody2D

## HPが変更されたときに発行されるシグナル
signal hp_changed(new_hp, max_hp)
## プレイヤーが死亡したときに発行されるシグナル
signal died
## 経験値が変更されたときに発行されるシグナル
signal exp_changed(current_exp, max_exp)
## レベルアップしたときに発行されるシグナル
signal level_up(new_level)

## プレイヤーの移動速度
@export var speed = 300.0
## プレイヤーの最大HP
@export var max_hp = 100
## プレイヤーの現在のHP
var hp = max_hp

## 現在のレベル
var level = 1
## 現在の経験値
var exp = 0
## 次のレベルに必要な経験値
var max_exp = 100

@onready var animation_player = $AnimationPlayer
@onready var sword_area = $WeaponPivot/Sword

## ノードがシーンツリーに入ったときに呼ばれる初期化関数
func _ready():
	hp = max_hp
	emit_signal("hp_changed", hp, max_hp)
	emit_signal("exp_changed", exp, max_exp)
	emit_signal("level_up", level)

## 物理プロセスの毎フレーム呼ばれる関数。移動とアニメーションを処理する。
func _physics_process(delta):
	# 入力方向を取得し、移動と減速を計算する
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		velocity = direction * speed
		# 移動方向に応じてスプライトを反転させる
		if direction.x < 0:
			$Sprite2D.flip_h = true
		elif direction.x > 0:
			$Sprite2D.flip_h = false
			
		# 攻撃中でなければ歩行アニメーションを再生する
		if animation_player.current_animation != "swing":
			animation_player.play("walk")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		# 攻撃中でなければ待機アニメーションを再生する
		if animation_player.current_animation != "swing":
			animation_player.play("idle")

	move_and_slide()

## ダメージを受ける関数
## @param amount: 受けるダメージ量
func take_damage(amount: int):
	hp -= amount
	emit_signal("hp_changed", hp, max_hp)
	if hp <= 0:
		emit_signal("died")

## 攻撃タイマーのタイムアウト時に呼ばれる処理。攻撃アニメーションを再生する。
func _on_attack_timer_timeout():
	animation_player.play("swing")

## 剣の当たり判定に別のボディが侵入したときの処理
## @param body: 侵入した物理ボディ
func _on_sword_body_entered(body):
	# 自分自身にはダメージを与えない
	if body == self:
		return
	# 相手が take_damage メソッドを持っていればダメージを与える
	if body.has_method("take_damage"):
		body.take_damage(1)

## 経験値を獲得し、必要ならレベルアップ処理を行う関数
## @param amount: 獲得する経験値量
func gain_exp(amount: int):
	exp += amount
	while exp >= max_exp:
		exp -= max_exp
		level += 1
		max_hp += 20 # レベルアップ時のHP上昇ボーナス
		hp = max_hp  # HP全回復
		max_exp = int(max_exp * 1.5) # 次のレベルに必要な経験値を増やす
		emit_signal("level_up", level)
		emit_signal("hp_changed", hp, max_hp)
	emit_signal("exp_changed", exp, max_exp)
