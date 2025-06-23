extends Area2D

func _ready() -> void:
	print("Spikes online")


func _on_body_entered(body: Node2D) -> void:
	print("something hit the spikes")
