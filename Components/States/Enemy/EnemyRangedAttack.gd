extends State
class_name EnemyRangedAttack

var enemy: BaseEnemy
#@export var max_range := 10.0
#@export var cooldown_duration := 3.0

@export var bullet := preload("res://Interactable/fireball/fireball.tscn")
@export var bullet_point: Node2D
@export var bullet_impact := preload("res://Interactable/fireball/fireball_explosion.tscn")

var cooldown_remaining := 0.0

var player: Player

func Enter():
	player = get_tree().get_first_node_in_group("Player")
	enemy = owner
	enemy.animated_sprite_2d.play("ranged")
	enemy.animated_sprite_2d.connect("animation_finished", on_animation_finished)
	var shot = bullet.instantiate()
	shot.direction = bullet_point.global_position.direction_to(player.global_position)
	shot.pos = bullet_point.global_position
	shot.target = player.global_position
	shot.explosion = bullet_impact
	get_tree().root.add_child(shot)

func on_animation_finished():
	Transitioned.emit(self, "EnemyIdle")
	pass
