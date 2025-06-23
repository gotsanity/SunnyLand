extends State
class_name EnemyPause

@export var pause_time := 5.0

func Enter():
	var animations = owner.get_node("AnimatedSprite2D")
	animations.play("idle")
	await get_tree().create_timer(pause_time).timeout
	Transitioned.emit(self, "EnemyIdle")
