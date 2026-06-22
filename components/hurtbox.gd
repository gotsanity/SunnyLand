class_name Hurtbox
extends Area2D

signal hit_react

var health_component: HealthComponent = null
@export var sprite: Node2D
@export var hit_react_length: float = 0.1

@onready var collision_shape_2d = $CollisionShape2D

func _ready():
	health_component = get_parent().get_node("HealthComponent")
	sprite = get_parent().get_node("AnimatedSprite2D")
	
	if not sprite:
		printerr(get_parent().name + " has no sprite set, please set one.")
	
	if not health_component:
		printerr("Health Component missing from " + get_parent().name + ", please add one")
	
	if not collision_shape_2d:
		printerr(get_parent().name + " needs a CollisionShape2D added to it's Hurtbox Component")
	else:
		if not collision_shape_2d.shape:
			printerr(get_parent().name + " needs a collision shape selected for it's Hurtbox Component")
	
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
	if area is Hitbox:
		if area.attack.team == owner.team:
			return
		if owner.is_dead || area.owner.is_dead:
			return
		
		if area.owner is Player:
			if int(area.owner.global_position.y + 2) < int(owner.global_position.y):
				damage(area.attack)
				area.on_hit()
				hit_react.emit(area.attack)
				area.owner.bounce_after_stomp()
				_apply_knockback(area)
		else:
			# Mirror of the stomp rule: if WE are the player and we're above the
			# attacker, we're stomping it — don't take contact damage this frame.
			if owner is Player and int(owner.global_position.y + 2) < int(area.owner.global_position.y):
				return
			damage(area.attack)
			area.on_hit()
			hit_react.emit(area.attack)
			_apply_knockback(area)


# Shove our owner away from the attacker, scaled by the attack's knockback_force.
# Safe for any owner: does nothing if the owner has no apply_knockback method.
func _apply_knockback(hit_area):
	if owner.has_method("apply_knockback"):
		owner.apply_knockback(hit_area.owner.global_position, hit_area.attack.knockback_force)


# Re-run the contact check against any Hitbox still overlapping us. Called by
# the HealthComponent when our i-frames end, because area_entered only fires on
# a fresh overlap — an enemy already standing in our space would otherwise never
# hit us again until we leave and re-enter.
func recheck_contacts():
	for area in get_overlapping_areas():
		if area is Hitbox:
			_on_area_entered(area)


func on_hit_react(_attack: Attack):
	if sprite:
		# Flash white
		sprite.modulate = Color(10, 10, 10, 10)
		
		# After timer elapses, set color back to normal
		await get_tree().create_timer(hit_react_length).timeout
		sprite.modulate = Color(1, 1, 1, 1)
