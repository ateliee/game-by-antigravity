extends Area2D

## プレイヤーに与える経験値量
@export var exp_amount = 20

func _on_body_entered(body):
	if body.name == "Player" and body.has_method("gain_exp"):
		body.gain_exp(exp_amount)
		queue_free()
