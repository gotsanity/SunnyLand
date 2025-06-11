extends CharacterBody2D

const SPEED = 30.0
const JUMP_VELOCITY = -300.0
var direction = -1
var attacking = false

@onready var animated_sprite_2d = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_on_floor() and !is_on_wall():
		velocity.x = SPEED * direction
	elif !is_on_floor():
		direction *= -1
		velocity.x = SPEED * direction
	else:
		direction *= -1
		velocity.x = SPEED * direction
	
	move_and_slide()
	update_animations(direction)


func update_animations(direction):
	if direction != 0:
		animated_sprite_2d.flip_h = direction > 0
	
	if attacking:
		animated_sprite_2d.play("attack")
	else:
		animated_sprite_2d.play("idle")
