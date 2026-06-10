extends Area2D


func spawn_feedback():
	var scene_to_spawn = preload("res://Pickups/Feedback/feedback.tscn")
	var new_scene_instance = scene_to_spawn.instantiate()
	get_tree().current_scene.add_child(new_scene_instance)  # Add the instance as a child of the current scene
	new_scene_instance.global_position = global_position


func _on_body_entered(body):
	# Only the player can collect it; grant the dash ability (Left Shift).
	if body is Player:
		body.has_dash = true
	spawn_feedback()
	queue_free()
