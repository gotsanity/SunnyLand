extends BaseEnemy

var attacking = false

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	super()
	SPEED = 60
