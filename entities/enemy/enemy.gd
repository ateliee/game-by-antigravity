extends CharacterBody2D

## 敵の移動速度
@export var speed = 50.0
## 敵のHP
@export var hp = 1
## プレイヤーへの参照
var player = null

## 死亡時に生成するパーティクルシーンのプリロード
const DEATH_PARTICLES = preload("res://entities/enemy/death_particles.tscn")
## ドロップする経験値アイテムのシーンプレロード
const EXP_ITEM_SCENE = preload("res://entities/items/exp_item.tscn")

## ノード初期化時に呼ばれる関数
func _ready():

	# プレイヤーノードを検索する処理（現在は未実装）
	pass

## 物理プロセスの毎フレーム呼ばれる関数。プレイヤーへの追従を処理する。
func _physics_process(delta):
	if player:
		# プレイヤーの方向に向かって移動する
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		
		# アニメーションプレイヤーがないための簡易的なアニメーション処理
		# 時間経過でフレームを切り替えて歩行を表現する
		var time = Time.get_ticks_msec() / 200
		$Sprite2D.frame = time % 2
		
		# 進行方向に応じてスプライトを反転させる
		if direction.x < 0:
			$Sprite2D.flip_h = false
		elif direction.x > 0:
			$Sprite2D.flip_h = true

## ダメージを受ける関数
## @param amount: 受けるダメージ量
func take_damage(amount: int):
	hp -= amount
	
	# 点滅エフェクト（ダメージを受けた際のアニメーション）
	if has_node("Sprite2D"):
		var tween = create_tween()
		tween.tween_property($Sprite2D, "modulate", Color.RED, 0.05)
		tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.05)
	
	if hp <= 0:
		die()

## 敵が死亡したときの処理
func die():
	# 死亡時のパーティクルを生成して配置する
	var particles = DEATH_PARTICLES.instantiate()
	particles.global_position = global_position
	particles.emitting = true
	# ツリーにパーティクルを追加する
	get_parent().add_child(particles)
	
	# 経験値アイテムをドロップする
	var exp_item = EXP_ITEM_SCENE.instantiate()
	exp_item.global_position = global_position
	get_parent().call_deferred("add_child", exp_item)
	
	# 自ノードを削除する
	queue_free()

## 敵の当たり判定（ヒットボックス）に別の物理ボディが侵入した時の処理
## @param body: 侵入した物理ボディ
func _on_hitbox_body_entered(body):
	if body.has_method("take_damage"):
		# プレイヤーかどうかを名前で確認し、ダメージを与える
		if body.name == "Player":
			body.take_damage(10) # ダメージ量の設定
			# 自爆（カミカゼ）してプレイヤーにダメージを与えた後に自身は消える
			die()
