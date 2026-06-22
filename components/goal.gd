extends Area2D

@export var next_scene := ""

func _ready():
	collision_mask = 3

func _on_body_entered(body):
	if body is Player:
		get_tree().change_scene_to_file(next_scene)
