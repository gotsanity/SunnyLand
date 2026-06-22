extends State
class_name EnemyFollow

var enemy: CharacterBody2D
@export var target_distance := 50
@export var follow_max_distance := 200

var player: CharacterBody2D

func Enter():
	enemy = owner
	player = get_tree().get_first_node_in_group('Player')
	var animations = enemy.get_node("AnimatedSprite2D")
	animations.play("idle")

func Physics_Update(delta: float):
	var direction
	if enemy.enable_flying:
		direction = player.global_position - enemy.global_position
	else:
		direction = Vector2(player.global_position.x - enemy.global_position.x, 0)
	
	
	enemy.direction = direction.x
	
	if direction.length() <= target_distance:
		enemy.velocity = Vector2.ZERO
		Transitioned.emit(self, enemy.attack.name)
	elif direction.length() > follow_max_distance:
		Transitioned.emit(self, "EnemyIdle")
	else:
		if not enemy.enable_flying:
			enemy.velocity.x = direction.normalized().x * enemy.SPEED
		else:
			enemy.velocity = direction.normalized() * enemy.SPEED
	
	enemy.move_and_slide()
