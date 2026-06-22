extends Pickup


func _on_body_entered(_body):
	spawn_feedback()
	queue_free()
