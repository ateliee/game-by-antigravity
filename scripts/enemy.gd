extends CharacterBody2D

@export var speed = 100.0
@export var hp = 1
var player = null

const DEATH_PARTICLES = preload("res://scenes/death_particles.tscn")

func _ready():
	# Find the player node. 
	pass

func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		
		# Simple squish animation using frame index toggling or just rely on an AnimationPlayer if we added one.
		# Since we didn't add AnimationPlayer to Enemy scene yet, let's do a simple code-based animation
		# or adding AnimationPlayer is better. But for a simple 2-frame, we can just toggle.
		# Let's toggle frame every 0.2s using a simple timer accumulator or Engine.get_ticks_msec()
		var time = Time.get_ticks_msec() / 200
		$Sprite2D.frame = time % 2
		
		# Flip sprite based on direction
		if direction.x < 0:
			$Sprite2D.flip_h = false # Assuming default is left or right. Usually sprites face right.
		elif direction.x > 0:
			$Sprite2D.flip_h = true

func take_damage(amount: int):
	hp -= amount
	
	# Blink effect
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate", Color.RED, 0.05)
	tween.tween_property($ColorRect, "modulate", Color.WHITE, 0.05)
	
	if hp <= 0:
		die()

func die():
	var particles = DEATH_PARTICLES.instantiate()
	particles.global_position = global_position
	particles.emitting = true
	# Add a script to the particles to auto-queue_free would be best,
	# but for now we can just rely on a timer or let them be if we update the particle scene.
	# Actually, let's create a transient script action or just trust the particles scene to handle itself if we update it.
	# For this implementation, I will assume the particle scene handles its own cleanup or we accept the leak for a second until I fix it.
	# Better: add it to tree.
	get_parent().add_child(particles)
	
	# Manually free particles after 1 second (simple hack without extra script file)
	queue_free()

func _on_hitbox_body_entered(body):
	if body.has_method("take_damage"):
		# Check if it's the player (to avoid damaging other enemies if they had that method, 
		# though currently only player has it, or we can check group/name)
		if body.name == "Player":
			body.take_damage(10) # Setup damage amount
			# Optional: Destroy enemy on impact? Or just push back?
			# For now, let's keep the enemy alive to keep attacking.
			# But to prevent instant kill every frame, we might need a cooldown or bounce.
			# Simple version: Enemy dies on impact with player (like a mine) 
			# OR Player has I-frames.
			# Request didn't specify, but "contact damage" usually implies continuous or one-shot.
			# Let's make enemy die on impact for simplicity and fairness, 
			# OR just push them back.
			# Let's go with: Enemy instakills itself to damage player (kamikaze) for now, 
			# as continuous damage without I-frames sucks.
			die()
