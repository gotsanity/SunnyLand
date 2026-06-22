extends CanvasLayer
## On-screen HUD: a health bar (top-left) and a dash hint (bottom-centre).
## The dash hint stays hidden until the player picks up the dash ability.

@onready var health_fill: ColorRect = $HealthBarFill
@onready var dash_hint: Label = $DashHint

var health_component: HealthComponent
var fill_left: float
var fill_full_width: float


func _ready():
	# Remember where the health bar fill starts and how wide it is when full,
	# so we can shrink it from the right as health drops.
	fill_left = health_fill.offset_left
	fill_full_width = health_fill.offset_right - health_fill.offset_left

	dash_hint.visible = false

	# The HUD lives under the player; fall back to the group just in case.
	var player = get_parent()
	if not (player is Player):
		player = get_tree().get_first_node_in_group("Player")
	if not player:
		return

	# --- Health ---
	health_component = player.get_node("HealthComponent")
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		_on_health_changed(health_component.health)   # show starting health

	# --- Dash hint ---
	if player.has_dash:                                # already unlocked
		dash_hint.visible = true
	if player.has_signal("dash_unlocked"):
		player.dash_unlocked.connect(_on_dash_unlocked)


func _on_health_changed(current_health: float):
	var fraction = clampf(current_health / health_component.max_health, 0.0, 1.0)
	health_fill.offset_right = fill_left + fill_full_width * fraction


func _on_dash_unlocked():
	dash_hint.visible = true
