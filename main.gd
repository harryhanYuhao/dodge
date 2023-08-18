extends Node

@export var mob_scene: PackedScene
@export var score: int

var projectResolution : Vector2

func _ready():
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	projectResolution.x=ProjectSettings.get_setting("display/window/size/viewport_width")
	projectResolution.y=ProjectSettings.get_setting("display/window/size/viewport_height")
	print(projectResolution)

func score_increase_by(i):
	score += i
	$HUD.update_score(score)

func score_set(i):
	score = i
	$HUD.update_score(score)

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$BackgroundSound.stop()
	$DeadSound.play()

func new_game():
	score_set(0)
	$BackgroundSound.play()
	get_tree().call_group("mobs", "queue_free")
	$Player.start($StartPosition.position)
	$StartTimer.start()


func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()


func _on_mob_timer_timeout():
		# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()
	#var mob = preload("res://mob.tscn").instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node("ModPath/MobSpawnLocation")
	mob_spawn_location.set_progress_ratio(randf_range(0.01, 0.95))

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2((score+10)/10 * randf_range(100.0, 150.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	
func _on_score_timer_timeout():
	score_increase_by(1)

func _on_hud_start_game():
	new_game() # Replace with function body.
