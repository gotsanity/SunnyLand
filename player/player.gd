extends CharacterBody2D
class_name Player


@export var SPEED = 110.0
@export var JUMP_VELOCITY = -300.0
@export var BOUNCE_HEIGHT = -400.0


# Jump feel: small grace windows that make platforming forgiving.
@export var COYOTE_TIME = 0.1       # how long after leaving a ledge you can still jump
@export var JUMP_BUFFER_TIME = 0.1  # how early a jump press is remembered before landing
var coyote_timer := 0.0
var jump_buffer_timer := 0.0

# Knockback: a hit shoves the player for a brief moment, overriding input.
@export var KNOCKBACK_DURATION = 0.2
var knockback_timer := 0.0
var knockback_velocity := Vector2.ZERO

# Dash ability (unlocked by the Strawberry pickup via unlock_dash()).
signal dash_unlocked                 # fired when the dash is granted (HUD listens)
@export var DASH_SPEED = 260.0       # how fast the dash moves
@export var DASH_DURATION = 0.15     # how long the dash lasts, in seconds
@export var DASH_COOLDOWN = 0.5      # wait time before you can dash again
var has_dash := false                # false until the strawberry is collected
var is_dashing := false
var dash_direction := 1.0
var dash_timer := 0.0
var dash_cooldown_timer := 0.0

@export var ranged_attack: Attack
@export var bullet = preload("res://interactable/fireball/fireball.tscn")
@export var bullet_point: Node2D
@export var bullet_impact = preload("res://interactable/fireball/fireball_explosion.tscn")

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

@onready var health_component : HealthComponent = $HealthComponent

# This function fires once when the player becomes ready
func _ready():
	health_component.died.connect(on_death)
	respawn_position = get_transform()


# This function fires many times a second to process physics
# delta provides how much time has passed since last fired.
func _physics_process(delta):
	# Update if we are currently in the air.
	was_in_air = not is_on_floor()

	# Coyote time: refill the grace window while grounded, otherwise tick it down
	# so a jump is still allowed for a moment after walking off a ledge.
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	# Jump buffering: remember a recent jump press so a press made just before
	# landing still fires the jump on touchdown.
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

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

	# Knockback: while the timer is active a hit is shoving us, so skip the
	# normal movement controls and just ride it out (gravity still applies).
	if knockback_timer > 0.0 and not dying:
		knockback_timer -= delta
		velocity.x = knockback_velocity.x
		move_and_slide()
		update_animations(0.0)
		return

	# If dying, bounce the player into the air
	if dying and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if (can_move):
		# Handle Jump. Fire if a buffered press lines up with a valid coyote
		# window, then consume both so the same press can't jump twice.
		if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0.0
			coyote_timer = 0.0

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


# Signal handler that triggers on death
func on_death():
	dying = true


# Event that triggers at the end of the death animation.
func die():
	dying = false
	was_in_air = false
	respawn()


# This function is called after landing on an enemy to shoot the player into the air
func bounce_after_stomp():
	velocity.y = BOUNCE_HEIGHT


# Shove the player away from from_position. Called when a hit lands; force is the
# attack's knockback_force (0 means no shove).
func apply_knockback(from_position: Vector2, force: float):
	if dying or is_dead or force <= 0.0:
		return
	knockback_velocity = (global_position - from_position).normalized() * force
	velocity = knockback_velocity
	knockback_timer = KNOCKBACK_DURATION


# Called by the Strawberry pickup to grant the dash and tell the HUD.
func unlock_dash():
	has_dash = true
	dash_unlocked.emit()


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
