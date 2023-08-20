extends Area2D 

signal hit
signal player_death
signal able_to_dash

var init_speed : float
var speed : float # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var max_speed : float

var dashable : bool

# When player would be controlable
var controllable : bool 

var shielded : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	# shall only be dashable after eating the dash icon
	dashable = false
	screen_size = get_viewport_rect().size
	var main = get_node("/root/Main")
	self.connect("player_death", Callable(main, "_on_player_death"))
	self.connect("hit", Callable(self, "_on_take_damage"))
	init_speed = Global.screenV2.length()/6
	speed = init_speed
	max_speed = Global.screenV2.length()/2
 
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not controllable:
		return
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if (Global.able_to_dash):
		if Input.is_action_just_pressed("dash"):
			var tmp = 2*init_speed + Global.score*Global.screenV2.length()/100
			if (tmp > max_speed):
				tmp = max_speed
			speed = tmp
		if Input.is_action_just_released("dash"):
			# do nothing 
			speed = init_speed

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

	
# player starts in random position
func start():
	position = Vector2(Global.randomf_in_screenX(), Global.randomf_in_screenY())
	$AnimatedSprite2D.animation = "walk"
	show()
	$CollisionShape2D.disabled = false
	controllable = true
	self.set_deferred("monitoring", true)
	shielded = false
	$AnimatedSpriteShield.hide()
 
func player_death_trigger():
	$AnimatedSprite2D.animation = "die"
	controllable = false
	player_death.emit()
	await get_tree().create_timer(1.0).timeout
	hide() # Player disappears after being hit.
		# Must be deferred as we can't change physics properties on a physics callback.

func _on_mob_hitted():
	Global.health -= 1
	self.set_deferred("monitoring", false)
	print("hitted!")

func _on_body_entered(body):
		# TEST: for debug
	if body.is_in_group("icon"):
		if (body.type == 1):
			emit_signal("able_to_dash")
			Global.able_to_dash = true
		if (body.type == 2):
			shielded = true
			$shield_get.play()
			$AnimatedSpriteShield.play()
			$AnimatedSpriteShield.show()	
		if (body.type == 3):
			$boom.play()
			get_tree().call_group("mobs", "queue_free")
		body.set_self_destruct()
	
	if body.is_in_group("mobs"):
		if (not shielded):
			Global.health -= 1
			print("shielded: ", shielded)
		self.set_deferred("monitoring", false)
		print("hitted!")
		hit.emit()
		# change of heart is in main script
		if(Global.health <= 0):
			player_death_trigger()
		elif shielded:
			$shield_pop.play()
			shielded = false
			self.modulate.a = 0.3
			await get_tree().create_timer(0.166).timeout
			self.modulate.a = 1.0	
			await get_tree().create_timer(0.166).timeout
			self.set_deferred("monitoring", true)
			$AnimatedSpriteShield.hide()
		else:
			$hitSound.play()
			for i in 3:
				self.modulate.a = 0.3
				await get_tree().create_timer(0.166).timeout
				self.modulate.a = 1.0	
				await get_tree().create_timer(0.166).timeout	
					# _on_body_enterred is only actinve if monitoring is true
			self.set_deferred("monitoring", true)
