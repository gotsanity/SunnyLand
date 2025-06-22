extends CharacterBody2D
class_name BaseEnemy

@export var SPEED = 40.0
@export var JUMP_VELOCITY = -400.0
@onready var health_component = $HealthComponent
@onready var movement_timer = $Timer
@onready var hurtbox = $Hurtbox
@onready var hitbox = $Hitbox

var direction := 1
var team := "enemy"
var is_dead := false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var enable_flying = false

func _ready():
	if isLoaded(health_component, "HealthComponent"):
		health_component.died.connect(on_death)
	
	if isLoaded(movement_timer, "Timer"):
		movement_timer.timeout.connect(_on_timer_timeout)
		movement_timer.autostart = true
	
	isLoaded(hurtbox, "Hurtbox")
	isLoaded(hitbox, "Hitbox")


func isLoaded(comp, comp_name):
	if not comp:
		printerr("Please add a " + comp_name + " component to " + name)
		return false
	
	return true


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
	is_dead = true
	queue_free()
