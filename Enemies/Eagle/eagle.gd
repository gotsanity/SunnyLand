extends BaseEnemy

var attacking = false

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	super()
	SPEED = 60

#func _physics_process(delta):
	## fly direction
	#if !is_on_floor() and !is_on_wall():
		#velocity.x = SPEED * direction
	#elif is_on_wall_only():
		#direction *= -1
		#velocity.x = SPEED * direction
	#
	#move_and_slide()
	#update_animations(direction)


func update_animations(direction):
	if direction != 0:
		animated_sprite_2d.flip_h = direction > 0
	
	if attacking:
		animated_sprite_2d.play("attack")
	else:
		animated_sprite_2d.play("default")
