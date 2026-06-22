extends Area2D

func _ready():
	collision_mask = 3
	pass

func _on_body_entered(body):
	if body is Player:
		body.respawn()
