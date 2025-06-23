extends State
class_name EnemyHop

var enemy: CharacterBody2D

@export var sec_between_hops := 2.0
@export var transition_after_hops := false
@export var max_num_hops := 1

var player: CharacterBody2D

var hop_timer: Timer
var animations: AnimatedSprite2D
var direction := -1.0
var hop_count := 0


func Enter():
	player = get_tree().get_first_node_in_group('Player')
	enemy = owner
	animations = enemy.get_node("AnimatedSprite2D")
	animations.play("idle")
	
	hop_timer = Timer.new()
	add_child(hop_timer)
	hop_timer.autostart = true
	hop_timer.one_shot = false
	hop_timer.wait_time = sec_between_hops
	hop_timer.connect("timeout", on_hop_timer_timeout)
	hop_timer.start()


func on_hop_timer_timeout():
	direction *= -1
	jump()


func Physics_Update(delta: float):
	if enemy.is_on_floor():
		# stop if is on the floor
		enemy.velocity.x = 0
		animations.play("idle")
		hop_count += 1
		
	else:
		# Add the gravity and move horizontally if is on air. 
		enemy.velocity.x = direction * enemy.SPEED
		enemy.velocity.y += enemy.gravity * delta
		if enemy.velocity.y > 0:
			animations.play("fall")
		else:
			animations.play("jump")

	enemy.move_and_slide()
	
	# flip sprite
	animations.flip_h = direction >0
	
	if transition_after_hops and hop_count > max_num_hops:
		Transitioned.emit(self, "EnemyIdle")


func jump():
	enemy.velocity.y = enemy.JUMP_VELOCITY
