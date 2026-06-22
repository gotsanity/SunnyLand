extends Pickup


func _on_body_entered(body):
	spawn_feedback()

	if body is Player:
		body.health_component.heal(1)

	queue_free()
