extends RigidBody2D

func randomVec():
	var res = Vector2(randf_range(-10000, 10000), randf_range(-10000, 10000))
	while (res.length() < 5000):
		res = Vector2(randf_range(-10000, 10000), randf_range(-10000, 10000))
	return res

func _ready():
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(mob_types[randi() % mob_types.size()])
#	var force = randomVec()
#	self.apply_force(force)
#	self.set_constant_torque(randf_range(0.1, 2))

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
