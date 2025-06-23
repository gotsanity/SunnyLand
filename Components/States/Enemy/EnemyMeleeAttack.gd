extends State
class_name EnemyMeleeAttack

var enemy: CharacterBody2D
@export var max_range := 0.0
@export var cooldown_duration := 3.0
@export var stand_still_while_attacking := false
@export var speed_multiplier := 1.0

var cooldown_remaining := 0.0

var player: CharacterBody2D
var animations: AnimatedSprite2D

func Enter():
	player = get_tree().get_first_node_in_group('Player')
	enemy = owner
	animations = enemy.get_node("AnimatedSprite2D")

func Exit():
	cooldown_remaining = 0.0

func Physics_Update(delta: float):
	if player.is_dead:
		Transitioned.emit(self, "EnemyPause")
		return
	
	var direction = player.global_position - enemy.global_position
	
	enemy.direction = direction.x
	
	if cooldown_remaining <= 0:
		cooldown_remaining = cooldown_duration
		attack()
	else:
		cooldown_remaining -= delta
	
	if not stand_still_while_attacking:
		move_forward()

func move_forward():
	var direction
	if enemy.enable_flying:
		direction = player.global_position - enemy.global_position
	else:
		direction = Vector2(player.global_position.x - enemy.global_position.x, 0)
	
	enemy.direction = direction.x
	
	enemy.velocity = direction.normalized() * (enemy.SPEED * speed_multiplier)
	enemy.move_and_slide()

func attack():
	animations.play("attack")
	animations.connect("animation_finished", on_anim_finished)

func on_anim_finished():
	Transitioned.emit(self, "EnemyFollow")
