class_name HurtBox
extends Area2D

@export var attack := Attack.new()

signal Impacted

func _ready():
	collision_layer = 3
	collision_mask = 0
	for child in get_children():
		if child is Attack:
			attack = child
	attack.source = owner


func on_hit():
	Impacted.emit(attack)
