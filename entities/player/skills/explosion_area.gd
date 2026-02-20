extends Area2D

var damage = 5
var progress = 0.0

func _ready():
	var tween = create_tween()
	# 生成時に少し大きくなるエフェクト
	scale = Vector2.ZERO
	# アニメーション用のprogressをtweenで動かす（0から1へ）
	tween.tween_property(self, "progress", 1.0, 0.3)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.2)
	tween.tween_callback(_explode)

func _process(delta):
	# _processで毎フレーム再描画をリクエストし、爆発の広がりを表現
	queue_redraw()

func _draw():
	# オレンジ・赤系の色で円を描画する
	var radius = 48.0 * progress
	if progress > 0.0:
		draw_circle(Vector2.ZERO, radius, Color(1.0, 0.4, 0.0, 0.8))
		draw_circle(Vector2.ZERO, radius * 0.7, Color(1.0, 0.8, 0.2, 0.9))
		draw_circle(Vector2.ZERO, radius * 0.4, Color(1.0, 0.9, 0.8, 1.0))

func _explode():
	# 半径内の敵にダメージ
	for body in get_overlapping_bodies():
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(damage)
	
	# すぐに消える
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.1)
	fade_tween.tween_callback(queue_free)
