extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("jump pad is online")
	$AnimatedSprite2D.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass






func _on_body_entered(body: Node2D) -> void:
	print("throw the player")
	
	# is the body that entered a player?
	if body is BaseEnemy or body is Player:
		
		#play animation
		$AnimatedSprite2D.play("launch")
		
		print("its a player, throw him")
		body.velocity.y = -500
	
	
	
	
	
	
	
