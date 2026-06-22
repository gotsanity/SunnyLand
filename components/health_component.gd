extends Node
class_name HealthComponent

@export var max_health := 1.0
var health: float
@export var hurtbox: Hurtbox

@export var invuln_duration := 0.0   # 0 = no i-frames (enemies); player set to ~1.0
@export var blink_interval := 0.1

var is_invulnerable := false

signal health_changed
signal died


func _ready():
	if !hurtbox:
		hurtbox = get_parent().get_node("Hurtbox")
	health = max_health


func reset():
	health = max_health
	health_changed.emit(health)


func damage(attack: Attack):
	if is_invulnerable:
		return
	print(get_parent().name + " has been attacked for: " + str(attack.attack_damage).pad_decimals(2))
	health = clampf(health - attack.attack_damage, 0, max_health)
	health_changed.emit(health)
	if hurtbox:
		hurtbox.hit_react.emit(attack)

	if health <= 0:
		owner.is_dead = true
		died.emit()
		return   # dead — skip i-frames

	if invuln_duration > 0.0:
		start_invulnerability()

func heal(amount: int):
	health = clampf(health + amount, 0, max_health)
	health_changed.emit(health)

# Brief post-hit invulnerability with a blinking sprite. Runs only when
# invuln_duration > 0 (the player); enemies leave it at 0 and are unaffected.
func start_invulnerability():
	is_invulnerable = true
	var sprite = hurtbox.sprite if hurtbox else null
	var elapsed := 0.0
	while elapsed < invuln_duration:
		# Await first so the white hit_react flash shows, then start blinking alpha.
		await get_tree().create_timer(blink_interval).timeout
		elapsed += blink_interval
		if sprite:
			sprite.modulate.a = 0.3 if sprite.modulate.a > 0.5 else 1.0
	is_invulnerable = false
	if sprite:
		sprite.modulate = Color(1, 1, 1, 1)   # hard restore — always fully visible afterward
	# If an enemy is still standing in our space, take the hit again now rather
	# than waiting for them to leave and re-enter (area_entered won't re-fire).
	if hurtbox:
		hurtbox.recheck_contacts()
