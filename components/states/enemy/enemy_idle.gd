extends State
class_name EnemyIdle

var move_direction : Vector2
var wander_time : float
var enemy: CharacterBody2D

@export var patrol := true
@export var patrol_distance := 100.0
@export var randomize_wander_time := false
@export var wander_timer := 3.0
@export var can_follow := true
@export var follow_distance := 40.0

var player: CharacterBody2D

func randomize_wander():
	move_direction = Vector2(randi_range(-1, 1), enemy.global_position.y)
	
	if randomize_wander_time:
		wander_time = randf_range(1, 3)
	else:
		wander_time = wander_timer

func set_patrol():
	if move_direction.x > 0:
		move_direction = Vector2(-1, enemy.global_position.y)
	else:
		move_direction = Vector2(1, enemy.global_position.y)
		
	wander_time = patrol_distance / enemy.SPEED

func Enter():
	player = get_tree().get_first_node_in_group('Player')
	enemy = owner
	var animations = enemy.get_node("AnimatedSprite2D")
	animations.play("idle")
	
	if patrol:
		set_patrol()
	else:
		randomize_wander()

func Update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		if patrol:
			set_patrol()
		else:
			randomize_wander()

func Physics_Update(delta: float):
	if enemy:
		enemy.velocity.x = move_direction.x * enemy.SPEED
	
	enemy.direction = move_direction.x
	
	if can_follow:
		var direction = player.global_position - enemy.global_position
		
		if direction.length() < follow_distance:
			Transitioned.emit(self, "EnemyFollow")
	
	enemy.move_and_slide()
