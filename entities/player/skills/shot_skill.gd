extends Node2D

@export var level: int = 1
var bullet_scene = preload("res://entities/player/skills/bullet.tscn")
var timer: Timer

func _ready():
	timer = Timer.new()
	timer.wait_time = 1.0 # 1秒ごとに発射
	timer.autostart = true
	timer.timeout.connect(_on_timeout)
	add_child(timer)

func _on_timeout():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		return
		
	# 一番近い敵を探す
	var nearest = null
	var min_dist = INF
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy
			
	if nearest:
		# レベルに応じて発射数を増やす
		for i in range(level):
			var bullet = bullet_scene.instantiate()
			bullet.global_position = global_position
			
			# 向き。複数発射時は少し扇状に広げる
			var angle_offset = (i - (level - 1) / 2.0) * 0.2
			var dir = (nearest.global_position - global_position).normalized().rotated(angle_offset)
			bullet.direction = dir
			bullet.rotation = dir.angle()
			
			get_tree().current_scene.add_child(bullet)
