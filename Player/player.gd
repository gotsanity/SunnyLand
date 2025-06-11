extends CharacterBody2D


const SPEED = 110.0
const JUMP_VELOCITY = -300.0
const JUMP_BONUS = -200.0
const SPEED_BONUS = 110.0

var crouching = false
var jumpBonus := -0.0
var crouchBonus = 1
var crouchTimer = Timer.new()

@onready var animated_sprite_2d = $AnimatedSprite2D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	crouchTimer.one_shot = true
	crouchTimer.autostart = false
	crouchTimer.wait_time = 3.0
	crouchTimer.timeout.connect(_on_crouchTimer_timeout)
	add_child(crouchTimer)


func _on_crouchTimer_timeout():
	animated_sprite_2d.speed_scale = 4.0
	print("crouch charged")
	jumpBonus = JUMP_BONUS
	crouchBonus = SPEED_BONUS
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY + jumpBonus

	# Handle Crouch
	if Input.is_action_just_pressed("ui_down") and is_on_floor():
		crouchTimer.start()

	if Input.is_action_pressed("ui_down") and is_on_floor():
		crouching = true

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


func update_animations(input_axis):
	animated_sprite_2d.speed_scale = move_toward(animated_sprite_2d.speed_scale, 1.0, 0.02)
	if input_axis != 0:
		animated_sprite_2d.flip_h = input_axis < 0
		animated_sprite_2d.play("run")
	elif crouching:
		animated_sprite_2d.play("crouch");
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")
