extends CharacterBody2D

## HPが変更されたときに発行されるシグナル
signal hp_changed(new_hp, max_hp)
## プレイヤーが死亡したときに発行されるシグナル
signal died
## 経験値が変更されたときに発行されるシグナル
signal exp_changed(current_exp, max_exp)
## レベルアップしたときに発行されるシグナル
signal level_up(new_level)
## スキル構成が変更されたときに発行されるシグナル
signal skills_changed(skills_array)

## プレイヤーの移動速度
@export var speed = 200.0
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

## アクティブスキルのリスト。各要素は {"id": String, "level": int}
var active_skills = []
## インスタンス化されたスキルノードの参照を保持する辞書
var skill_nodes = {}

@onready var animation_player = $AnimationPlayer
@onready var sword_area = $WeaponPivot/Sword

## ノードがシーンツリーに入ったときに呼ばれる初期化関数
func _ready():
	hp = max_hp
	# デフォルトで剣スキルをLv1で所持
	active_skills.append({"id": "sword", "level": 1})
	emit_signal("skills_changed", active_skills)
	
	emit_signal("hp_changed", hp, max_hp)
	emit_signal("exp_changed", exp, max_exp)
	emit_signal("level_up", level)

## 物理プロセスの毎フレーム呼ばれる関数。移動とアニメーションを処理する。
func _physics_process(delta):
	# レベルアップの保留確認（ポーズ中はここは呼ばれない）
	if exp >= max_exp:
		exp -= max_exp
		level += 1
		max_exp = int(max_exp * 1.5)
		emit_signal("level_up", level)
		emit_signal("exp_changed", exp, max_exp)
		return # 今回のフレームはレベルアップ処理を行い、移動処理は一時停止
		
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

## 経験値を獲得する処理（レベルアップ判定は _physics_process で行う）
## @param amount: 獲得する経験値量
func gain_exp(amount: int):
	exp += amount
	emit_signal("exp_changed", exp, max_exp)

## UIから選択されたアップグレードを自身のステータスに適用する
## @param upgrade_id: 適用するアップグレードの識別子
func apply_upgrade(upgrade_id: String):
	match upgrade_id:
		"max_hp_up":
			max_hp += 20
			hp += 20
			emit_signal("hp_changed", hp, max_hp)
		"heal_full":
			hp = max_hp
			emit_signal("hp_changed", hp, max_hp)
		"speed_up":
			speed += 50.0
		"sword", "shot", "explosion":
			_acquire_skill(upgrade_id)

## スキルの取得またはレベルアップ処理を行う
func _acquire_skill(skill_id: String):
	var found = false
	for skill in active_skills:
		if skill.id == skill_id:
			skill.level = min(skill.level + 1, 3)
			if skill_nodes.has(skill_id):
				skill_nodes[skill_id].level = skill.level
			found = true
			break
			
	if not found:
		if active_skills.size() >= 6:
			var oldest = active_skills.pop_front() # 一番古いスキルを破棄 (FIFO)
			if skill_nodes.has(oldest.id):
				skill_nodes[oldest.id].queue_free()
				skill_nodes.erase(oldest.id)
			elif oldest.id == "sword":
				# 剣は捨てられないよう特別扱いにするか、捨てられたら攻撃不能にするか
				# 今回は物理的に消すノードがないのでパス
				pass
				
		active_skills.append({"id": skill_id, "level": 1})
		
		# 剣以外の新しいスキルノードを生成して追加
		if skill_id != "sword":
			var new_skill_node = Node2D.new()
			new_skill_node.name = skill_id.capitalize() + "Skill"
			if skill_id == "shot":
				new_skill_node.set_script(preload("res://entities/player/skills/shot_skill.gd"))
			elif skill_id == "explosion":
				new_skill_node.set_script(preload("res://entities/player/skills/explosion_skill.gd"))
				
			add_child(new_skill_node)
			skill_nodes[skill_id] = new_skill_node
			
	# 剣スキルのレベルアップ適用
	if skill_id == "sword":
		var s_level = 1
		for s in active_skills:
			if s.id == "sword":
				s_level = s.level
				break
		# レベルに応じて攻撃範囲（またはダメージ等）を強化
		var sc = 1.0 + (s_level - 1) * 0.2
		$WeaponPivot/Sword/CollisionShape2D.scale = Vector2(sc, sc)
		if $WeaponPivot/Sword.has_node("Visual"):
			$WeaponPivot/Sword/Visual.scale = Vector2(sc, sc)
		$AttackTimer.wait_time = max(0.2, 0.5 - (s_level - 1) * 0.1) # 攻撃速度UP
		
	emit_signal("skills_changed", active_skills)
