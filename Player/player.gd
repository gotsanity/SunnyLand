extends CharacterBody2D
class_name Player


const SPEED = 110.0
const JUMP_VELOCITY = -300.0
const JUMP_BONUS = -200.0
const SPEED_BONUS = 110.0
var can_move = true
var crouching = false
var jumpBonus := -0.0
var crouchBonus = 1
var crouchTimer = Timer.new()
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
	crouchTimer.one_shot = true
	crouchTimer.autostart = false
	crouchTimer.wait_time = 3.0
	crouchTimer.timeout.connect(_on_crouchTimer_timeout)
	add_child(crouchTimer)
	health_component.died.connect(on_death)
	respawn_position = get_transform()


# When crouch timer finishes, charge up animations and add jump height and speed
func _on_crouchTimer_timeout():
	animated_sprite_2d.speed_scale = 4.0
	jumpBonus = JUMP_BONUS
	crouchBonus = SPEED_BONUS


# This function fires many times a second to process physics
# delta provides how much time has passed since last fired.
func _physics_process(delta):
	# Update if we are currently in the air.
	was_in_air = not is_on_floor()
	
	# Add the gravity.
	if was_in_air:
		velocity.y += gravity * delta
	
	# If dying, bounce the player into the air
	if dying and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if (can_move):
		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY + jumpBonus

		# Handle Crouch timer
		if Input.is_action_just_pressed("ui_down") and is_on_floor():
			crouchTimer.start()
		
		# Handle continuous crouching
		if Input.is_action_pressed("ui_down") and is_on_floor():
			crouching = true
		
		# Crouching released, stop timer
		if Input.is_action_just_released("ui_down"):
			crouching = false
			if crouchTimer.wait_time > 0:
				crouchTimer.stop()

		# Get the input direction (input_axis) and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_axis = Input.get_axis("ui_left", "ui_right")
		if input_axis:
			velocity.x = input_axis * (SPEED + crouchBonus)
			crouchBonus = move_toward(crouchBonus, 0, 1)
		else:
			crouchBonus = move_toward(crouchBonus, 0, 1)
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		jumpBonus = move_toward(jumpBonus, 0, 1)
		
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


# Signal handler that triggers on death
func on_death():
	dying = true


# Event that triggers at the end of the death animation.
func die():
	print("Player has died")
	dying = false
	was_in_air = false
	respawn()


# This function is called when the player is respawned.
# It disables the player for a short time and then reenables it
# and sets the position to the last set respawn point
func respawn():
	self.visible = false
	can_move = false
	is_dead = true
	await get_tree().create_timer(respawn_timer_length).timeout
	self.global_position = respawn_position.get_origin()
	self.visible = true
	can_move = true
	is_dead = false
