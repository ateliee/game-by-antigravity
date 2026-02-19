extends CharacterBody2D

signal hp_changed(new_hp)
signal died

@export var speed = 300.0
@export var max_hp = 100
var hp = max_hp

@onready var animation_player = $AnimationPlayer
@onready var sword_area = $WeaponPivot/Sword

func _ready():
	hp = max_hp
	emit_signal("hp_changed", hp)

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		velocity = direction * speed
		# Flip sprite based on direction
		if direction.x < 0:
			$Sprite2D.flip_h = true
		elif direction.x > 0:
			$Sprite2D.flip_h = false
			
		# Play walk animation if not attacking
		if animation_player.current_animation != "swing":
			animation_player.play("walk")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		# Play idle if not attacking
		if animation_player.current_animation != "swing":
			animation_player.play("idle")

	move_and_slide()

func take_damage(amount: int):
	hp -= amount
	emit_signal("hp_changed", hp)
	if hp <= 0:
		emit_signal("died")

func _on_attack_timer_timeout():
	animation_player.play("swing")

func _on_sword_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(1)
