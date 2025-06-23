extends Area2D

@onready var collision_shape_2d = $CollisionShape2D

func _ready():
	collision_mask = 3
	pass

func _on_body_entered(body):
	if body is Player:
		body.respawn()
