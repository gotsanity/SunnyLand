extends Node2D

var start_position : Vector2

@export var drop_duration = 0.4
@export var lift_duration = 2.0
@export var wait_time = 1.0
@export var attack : Attack

var dropping := false

@onready var timer: Timer = $Timer

@onready var ray_cast_2d: RayCast2D = $AnimatableBody2D/RayCast2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = global_position
	timer.wait_time = wait_time * randf_range(0.0, 1.0)


func _on_timer_timeout() -> void:
	dropping = !dropping
	var tween = get_tree().create_tween()
	if dropping:
		tween.tween_property(self, "position", start_position + ray_cast_2d.target_position, drop_duration)
		tween.tween_callback(play_anim)
	else:
		tween.tween_property(self, "position", start_position, lift_duration)

func play_anim():
	$AnimatableBody2D/AnimatedSprite2D.play("bottom_hit")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.health_component.damage(attack)
