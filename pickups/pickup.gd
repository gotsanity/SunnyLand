extends Area2D
class_name Pickup

# Shared base for every pickup (cherry, gem, strawberry, ...).
# It holds the one piece of behaviour they all share: showing the little
# "feedback" pop when the pickup is collected. Each pickup script extends
# this class with "extends Pickup" and only writes what makes it special.

const FEEDBACK_SCENE = preload("res://pickups/feedback/feedback.tscn")


# Spawns the feedback pop at this pickup's position.
func spawn_feedback():
	var instance = FEEDBACK_SCENE.instantiate()
	get_tree().current_scene.add_child(instance)
	instance.global_position = global_position
