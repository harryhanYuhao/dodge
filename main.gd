extends Node

@export var mob_scene: PackedScene
@export var score: int

var projectResolution : Vector2
var dash_signal_emitted : bool
var heart_Array : Array
var cur_maxHealth : int

#var dash_icon

func _ready():
	# generate randomized seed
	randomize()
	$HUD.update_score()
	$HUD.show_message("Get Ready!\n Arrow Keys to Move!")
	projectResolution.x=ProjectSettings.get_setting("display/window/size/viewport_width")
	projectResolution.y=ProjectSettings.get_setting("display/window/size/viewport_height")
	print(projectResolution)
	$StartTimer.wait_time = 1
	# for test:
	$StartTimer.wait_time = 0.1

	
	#set heart
	
	for i in Global.maxhealth:
		var tmp = load("res://heart.tscn").instantiate()
		add_child(tmp)
		tmp.position = Vector2((Global.screenX*(14-0.5*i))/15, Global.screenY/15)
		tmp.full_heart()
		tmp.show()
		heart_Array.append(tmp)
	
func new_game():
	score_set(0)
	Global.game_over = false
	Global.icon_listeners = []
	$BackgroundSound.play()
	get_tree().call_group("mobs", "queue_free")
	$Player.start()
	$StartTimer.start()
	Global.health = Global.maxhealth
	#Global.maxhealth = 3
	Global.able_to_dash = false
	dash_signal_emitted = false
	# debug
	generate_icon("dash", randf_range(1.5, 8))
#	generate_icon("shield", 1)
	#generate_icon("boom", 1)

	for i in heart_Array:
		i.full_heart()

func _process(delta):
	if (Global.able_to_dash and !dash_signal_emitted):
		dash_signal_emitted = true
		$HUD.show_message("keep Pressing D to Dash!")
		$Dash_icon_eaten.play()


func generate_icon(name, wait_time):
	var icon = load("res://icon.tscn").instantiate()
	icon.icon_init(name, wait_time)
	add_child(icon)
		
func score_increase_by(i):
	Global.score += i
	$HUD.update_score()
	if (Global.score%10 == 1):
		generate_icon("shield", randf_range(0.5, 3))
	if (Global.score%20 == 1):
		generate_icon("boom", randf_range(0.5, 3))

func score_set(i):
	Global.score = i
	$HUD.update_score()


func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

# set mob property according to index
# need an already instantiated mob and direction for velocity
func set_mob_property(mob, position, direction, index):
	var velocity = Vector2((index+10)/7 * randf_range(70.0, 200.0)+Global.screenV2.length()/20, 0.0)
	mob.set_inertia(1.0)
	mob.linear_velocity = velocity.rotated(direction)
	mob.apply_torque(velocity.length()/100*randf_range(1, 50))
	mob.position = position
	#print(mob.linear_velocity.length())

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

	direction += randf_range(-PI / 4, PI / 4)

	# Choose the velocity for the mob.
	set_mob_property(mob, mob_spawn_location.position, direction, Global.score)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	
func _on_score_timer_timeout():
	score_increase_by(1)
	$MobTimer.wait_time = 1.0/(1*score+2)
	# TEST:
	#print("mob wait_time: (calls from main._on_score_timer_timeout) %20.6f"%$MobTimer.wait_time)
	
func _on_hud_start_game():
	new_game() # Replace with function body.

func _on_player_death():
	print("player_death received!")
	game_over()


func _on_player_hit():
	for i in (Global.maxhealth-Global.health):
		heart_Array[i].empty_heart()
	pass

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$BackgroundSound.stop()
	$DeadSound.play()
	Global.game_over = true
