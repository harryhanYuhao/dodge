extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	show() # Replace with function body.

func full_heart():
	$AnimatedSprite2D.animation = "full"

func empty_heart():
	$AnimatedSprite2D.animation = "empty"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
