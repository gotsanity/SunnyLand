extends BaseEnemy

func _physics_process(delta):
	
	if  is_on_floor():
		# stop if is on the floor
		velocity.x = 0
		$AnimatedSprite2D.play("idle")
		
	else:
		# Add the gravity and move horizontally if is on air. 
		velocity.x = direction * SPEED
		velocity.y += gravity * delta
		if velocity.y > 0:
			$AnimatedSprite2D.play("fall")
		else:
			$AnimatedSprite2D.play("jump")

	move_and_slide()
	
	# flip sprite
	$AnimatedSprite2D.flip_h = direction >0
	
	
func jump():
	velocity.y = JUMP_VELOCITY


func _on_timer_timeout():
	# when timer finish, change direction and jump
	direction *= -1
	jump()
