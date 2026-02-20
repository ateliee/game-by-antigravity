extends Node2D

@export var level: int = 1
var explosion_scene = preload("res://entities/player/skills/explosion_area.tscn")
var timer: Timer

func _ready():
	timer = Timer.new()
	timer.wait_time = 2.5 # 2.5秒ごとに発動
	timer.autostart = true
	timer.timeout.connect(_on_timeout)
	add_child(timer)

func _on_timeout():
	var viewport_size = get_viewport_rect().size
	var camera = get_viewport().get_camera_2d()
	var center = global_position
	if camera:
		center = camera.get_screen_center_position()
		
	# レベルに応じて発生回数を増やす (Lv1=1, Lv2=2, Lv3=3)
	for i in range(level):
		var exp_area = explosion_scene.instantiate()
		
		# 画面内のランダムな位置に爆発を生成
		var rx = randf_range(center.x - viewport_size.x / 2.0, center.x + viewport_size.x / 2.0)
		var ry = randf_range(center.y - viewport_size.y / 2.0, center.y + viewport_size.y / 2.0)
		
		exp_area.global_position = Vector2(rx, ry)
		exp_area.damage = 5 + (level * 2) # レベルに応じてダメージ増加
		
		get_tree().current_scene.add_child(exp_area)
