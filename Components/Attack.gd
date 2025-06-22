extends Node
class_name Attack

@export var attack_damage: float = 1.0
@export var knockback_force: float = 0.0
@export var attack_position: Vector2 = Vector2.ZERO
@export var source: CharacterBody2D
@export var team := "enemy"
