extends Area2D

@export var attack: Attack

func _ready() -> void:
	print("Spikes online")


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.health_component.damage(attack)
		print("something hit the spikes")
