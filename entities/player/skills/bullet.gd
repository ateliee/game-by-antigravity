extends Area2D

var speed = 400.0
var direction = Vector2.RIGHT
var damage = 1

func _ready():
	# 画面外に出た時に消えるようにする処理などはここに追加できる
	pass

func _draw():
	# 青い魔法弾の描画 (頂点数分と同じ要素数のColorArrayが必要、または単色)
	var colors = PackedColorArray([Color(0.2, 0.8, 1.0, 1.0)])
	var point_array = PackedVector2Array([
		Vector2(10, 0),
		Vector2(0, 5),
		Vector2(-15, 0),
		Vector2(0, -5)
	])
	draw_polygon(point_array, colors)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()

func _on_timer_timeout():
	queue_free()
