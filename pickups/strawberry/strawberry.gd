extends Pickup


func _on_body_entered(body):
	# Only the player can collect it; grant the dash ability (Left Shift).
	if body is Player:
		body.unlock_dash()
	spawn_feedback()
	queue_free()
