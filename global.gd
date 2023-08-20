extends Node

# This is autoload

# Called when the node enters the scene tree for the first time.
var score : int = 0
var screenX : float 
var screenY : float
var screenV2 : Vector2
var able_to_dash : bool = false
var maxhealth : int = 3
var health : int

var icon_listeners : Array
var icon_counter : int
var game_over : int

func randomf_in_screenX():
	return randf_range(0, screenX)

func randomf_in_screenY():
	return randf_range(0, screenY)

func _ready():
	screenV2 = get_viewport().get_visible_rect().size
	screenX = screenV2.x
	screenY = screenV2.y

func get_mob_speed():
	pass
	
func get_mob_timer_wait_time():
	pass
	
func _process(delta):
	pass
