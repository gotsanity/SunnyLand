class_name Hitbox
extends Area2D

signal hit_react

var health_component: HealthComponent = null
@export var sprite: Node2D
@export var hit_react_length: float = 0.1

func _ready():
	health_component = get_parent().get_node("HealthComponent")
	sprite = get_parent().get_node("AnimatedSprite2D")
	
	if not sprite:
		printerr(get_parent().name + " has no sprite set, please set one.")
	
	if not health_component:
		printerr("Health Component missing from " + get_parent().name + ", please add one")
	
	# Set collisions
	collision_layer = 0
	collision_mask = 3
	
	# Connect signals for hit react and area entered
	hit_react.connect(on_hit_react)
	area_entered.connect(_on_area_entered)


func damage(attack: Attack):
	if health_component:
		health_component.damage(attack)


func _on_area_entered(area):
	if area is HurtBox and area.attack.source != owner:
		damage(area.attack)
		area.on_hit()
		hit_react.emit(area.attack)


func on_hit_react(attack: Attack):
	if sprite:
		# Flash white
		sprite.modulate = Color(10, 10, 10, 10)
		
		# After timer elapses, set color back to normal
		await get_tree().create_timer(hit_react_length).timeout
		sprite.modulate = Color(1, 1, 1, 1)
