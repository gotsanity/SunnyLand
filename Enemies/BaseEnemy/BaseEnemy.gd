extends CharacterBody2D
class_name BaseEnemy

@export var SPEED = 40.0
@export var JUMP_VELOCITY = -400.0
@onready var health_component = $HealthComponent
@onready var hurtbox = $Hurtbox
@onready var hitbox = $Hitbox
@onready var animated_sprite_2d = $AnimatedSprite2D

@export var attack : State
@onready var state_machine = $StateMachine
@onready var initial_state = $StateMachine/EnemyIdle

var direction := 1.0
var team := "enemy"
var is_dead := false
var can_move := true
var attacking := false
var initial_position: Vector2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var enable_flying = false

func _ready():
	initial_position = global_position
	if isLoaded(health_component, "HealthComponent"):
		health_component.died.connect(on_death)
	
	isLoaded(hurtbox, "Hurtbox")
	isLoaded(hitbox, "Hitbox")
	
	if isLoaded(state_machine, "StateMachine"):
		if !state_machine.initial_state:
			printerr("Please set an Initial State on the State Machine for " + name)


func isLoaded(comp, comp_name):
	if not comp:
		printerr("Please add a " + comp_name + " component to " + name)
		return false
	
	return true


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() and not enable_flying:
		velocity.y += gravity * delta
	
	update_animations()


func update_animations():
	# change sprite direction
	if direction > 0:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false


# Handle death signal
func on_death():
	is_dead = true
	can_move = false
	for child in get_children():
		if child is Hitbox or child is Hurtbox:
			child.queue_free()
		pass
	await get_tree().create_timer(0.5).timeout
	queue_free()
