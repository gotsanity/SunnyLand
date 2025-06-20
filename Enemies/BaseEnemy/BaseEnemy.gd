extends CharacterBody2D
class_name BaseEnemy

@export var SPEED = 40.0
@export var JUMP_VELOCITY = -400.0
@onready var health_component = $HealthComponent

var direction := 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var enable_flying = false

func _ready():
	if health_component:
		health_component.died.connect(on_death)
	else:
		printerr("Please add a health component to " + name)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() and not enable_flying:
		velocity.y += gravity * delta

	velocity.x = direction * SPEED

	move_and_slide()
	
	# change sprite direction
	if direction > 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false


func _on_timer_timeout():
	direction *= -1


# Handle death signal
func on_death():
	queue_free()
