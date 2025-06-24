extends Node
class_name HealthComponent

@export var max_health := 1.0
var health: float

signal health_changed
signal died


func _ready():
	health = max_health


func reset():
	health = max_health
	health_changed.emit(health)


func damage(attack: Attack):
	print(get_parent().name + " has been attacked for: " + str(attack.attack_damage).pad_decimals(2))
	health -= clampf(attack.attack_damage, 0, max_health)
	health_changed.emit(health)
	get_parent().get_node("Hitbox").hit_react.emit(attack)
	
	if health <= 0:
		owner.is_dead = true
		died.emit() 
