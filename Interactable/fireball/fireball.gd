extends CharacterBody2D
class_name Fireball

var pos: Vector2
var target: Vector2
var rot: float
var direction: Vector2
var speed := 100
@export var attack: Attack
@export var time_to_live: float = 2.0
@export var explosion = preload("res://Interactable/fireball/fireball_explosion.tscn")


var timer: Timer

func _ready():
	global_position = pos
	look_at(target)
	await get_tree().create_timer(time_to_live).timeout
	explode()

func _physics_process(_delta):
	velocity = direction * speed
	move_and_slide()

func explode():
	var boom = explosion.instantiate()
	boom.global_position = global_position
	get_tree().root.add_child(boom)
	queue_free()

func on_timeout():
	explode()

func _on_area_2d_body_entered(body):
	if body is Player and attack.team == "enemy":
		body.health_component.damage(attack)
		explode()
	
	if body is BaseEnemy and attack.team == "player":
		body.health_component.damage(attack)
		explode()
