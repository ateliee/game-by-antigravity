extends Area2D

## プレイヤーに与える経験値量
@export var exp_amount = 20
## 引き寄せが始まる距離（ピクセル）
@export var magnet_radius = 150.0
## 引き寄せられる速度
@export var magnet_speed = 300.0

## プレイヤーノードの参照キャッシュ
var player = null

func _ready():
	# プレイヤーノードを探して保存する
	var group_nodes = get_tree().get_nodes_in_group("player")
	if group_nodes.size() > 0:
		player = group_nodes[0]
	else:
		# グループがない場合はパスで探すか親から探す
		player = get_parent().get_node_or_null("Player")

func _physics_process(delta):
	# プレイヤーが存在し、一定距離内ならプレイヤーの方向へ移動する
	if player and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)
		if distance < magnet_radius:
			var direction = (player.global_position - global_position).normalized()
			# 近づくほど少し加速させる（オプショナル）
			var speed_multiplier = clamp(1.0 - (distance / magnet_radius), 0.5, 1.0)
			global_position += direction * magnet_speed * speed_multiplier * delta

func _on_body_entered(body):
	if body.name == "Player" and body.has_method("gain_exp"):
		body.gain_exp(exp_amount)
		queue_free()
