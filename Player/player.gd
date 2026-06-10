extends CharacterBody2D
class_name Player


@export var SPEED = 110.0
@export var JUMP_VELOCITY = -300.0
@export var BOUNCE_HEIGHT = -300.0

# Dash ability (unlocked by the Strawberry pickup, which sets has_dash = true).
@export var DASH_SPEED = 260.0       # how fast the dash moves
@export var DASH_DURATION = 0.15     # how long the dash lasts, in seconds
@export var DASH_COOLDOWN = 0.5      # wait time before you can dash again
var has_dash := false                # false until the strawberry is collected
var is_dashing := false
var dash_direction := 1.0
var dash_timer := 0.0
var dash_cooldown_timer := 0.0

@export var ranged_attack: Attack
@export var bullet = preload("res://Interactable/fireball/fireball.tscn")
@export var bullet_point: Node2D
@export var bullet_impact = preload("res://Interactable/fireball/fireball_explosion.tscn")

var can_move = true
var crouching = false

var respawn_position: Transform2D
var team := "player"
var is_dead = false

@export var respawn_timer_length := 3.0

var was_in_air := false
var dying := false

@onready var animated_sprite_2d = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var health_component = $HealthComponent

# This function fires once when the player becomes ready
func _ready():
	health_component.died.connect(on_death)
	respawn_position = get_transform()


# This function fires many times a second to process physics
# delta provides how much time has passed since last fired.
func _physics_process(delta):
	# Update if we are currently in the air.
	was_in_air = not is_on_floor()

	# Count down the dash cooldown so we can dash again later.
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	# Start a dash the moment Shift is pressed (once it's unlocked and ready).
	if can_move and not dying and has_dash and Input.is_action_just_pressed("dash") \
			and not is_dashing and dash_cooldown_timer <= 0.0:
		start_dash()

	# While dashing, shoot straight sideways and ignore gravity for a moment.
	if is_dashing:
		dash_timer -= delta
		if dash_timer > 0.0:
			velocity.x = dash_direction * DASH_SPEED
			velocity.y = 0.0
			animated_sprite_2d.flip_h = dash_direction < 0
			animated_sprite_2d.play("run")
			move_and_slide()
			return
		else:
			is_dashing = false

	# Add the gravity.
	if was_in_air:
		velocity.y += gravity * delta
	
	# If dying, bounce the player into the air
	if dying and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if (can_move):
		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		if Input.is_action_just_pressed("shoot"):
			shoot()

		# Get the input direction (input_axis) and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_axis = Input.get_axis("ui_left", "ui_right")
		if input_axis:
			velocity.x = input_axis * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		move_and_slide()
		update_animations(input_axis)
	
	# Check if dying is finished (landed). Then trigger on death
	# finished.
	if was_in_air and is_on_floor() and dying:
		die()


# This function fires every time the physics are processed and
# handles all animation updates.
func update_animations(input_axis):
	# Bringing animations back to normal speed.
	animated_sprite_2d.speed_scale = move_toward(animated_sprite_2d.speed_scale, 1.0, 0.02)
	
	# Choose animation (and direction) based on movement input
	if input_axis != 0:
		animated_sprite_2d.flip_h = input_axis < 0
		animated_sprite_2d.play("run")
	elif crouching:
		animated_sprite_2d.play("crouch");
	else:
		animated_sprite_2d.play("idle")
	
	# Handle vertical movement (jumping, on hit)
	if was_in_air and not dying:
		animated_sprite_2d.play("jump")
	elif was_in_air and dying:
		animated_sprite_2d.play("death")


# Spawns a fireball at a point on the player
func shoot():
	var mouse_position = get_global_mouse_position()
	var shot = bullet.instantiate()
	shot.attack = ranged_attack
	shot.direction = bullet_point.global_position.direction_to(mouse_position).normalized()
	shot.pos = bullet_point.global_position
	shot.target = mouse_position
	shot.explosion = bullet_impact
	get_tree().root.add_child(shot)
	pass


# Signal handler that triggers on death
func on_death():
	dying = true


# Event that triggers at the end of the death animation.
func die():
	print("Player has died")
	dying = false
	was_in_air = false
	respawn()


# This function is called after landing on an enemy to shoot the player into the air
func bounce_after_stomp():
	velocity.y = BOUNCE_HEIGHT


# Kicks off a dash. Dash in the direction we're pressing, or the way we're
# facing if no direction is held. Also starts the cooldown timer.
func start_dash():
	is_dashing = true
	dash_timer = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN
	var input_axis = Input.get_axis("ui_left", "ui_right")
	if input_axis != 0:
		dash_direction = signf(input_axis)
	else:
		dash_direction = -1.0 if animated_sprite_2d.flip_h else 1.0


# This function is called when the player is respawned.
# It disables the player for a short time and then reenables it
# and sets the position to the last set respawn point
func respawn():
	self.visible = false
	can_move = false
	is_dead = true
	await get_tree().create_timer(respawn_timer_length).timeout
	# Reload the whole level so killed enemies (and pickups) come back.
	# The player starts at the level's beginning, same as respawn_position.
	get_tree().reload_current_scene()
