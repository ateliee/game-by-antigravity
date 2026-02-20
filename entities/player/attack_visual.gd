extends Node2D

func _draw():
	# 三日月型（スラッシュ）の描画
	var colors = PackedColorArray([Color(1.0, 1.0, 1.0, 0.8), Color(0.8, 0.9, 1.0, 0.4)])
	
	# 外側の円弧と内側の円弧を使って三日月を作る
	var points = PackedVector2Array()
	var point_count = 16
	var radius_outer = 65.0
	var radius_inner = 45.0
	var angle_start = -PI / 6.0
	var angle_end = PI / 6.0
	
	# 外側のカーブ
	for i in range(point_count + 1):
		var t = float(i) / point_count
		var angle = lerp(angle_start, angle_end, t)
		points.append(Vector2(cos(angle), sin(angle)) * radius_outer + Vector2(25, 0))
		
	# 内側のカーブ（逆順）
	for i in range(point_count + 1):
		var t = float(point_count - i) / point_count
		var angle = lerp(angle_start, angle_end, t)
		points.append(Vector2(cos(angle), sin(angle)) * radius_inner + Vector2(25, 0))
		
	draw_colored_polygon(points, Color(1, 1, 1, 0.7))
