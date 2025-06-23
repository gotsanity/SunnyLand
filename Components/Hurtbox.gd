class_name Hurtbox
extends Area2D

@export var attack := Attack.new()
@onready var collision_shape_2d = $CollisionShape2D

signal Impacted

func _ready():
	if not collision_shape_2d:
		printerr(get_parent().name + " needs a CollisionShape2D added to it's Hurtbox Component")
	
	collision_layer = 3
	collision_mask = 0
	for child in get_children():
		if child is Attack:
			attack = child
	attack.source = owner
	attack.team = owner.team


func on_hit():
	Impacted.emit(attack)
