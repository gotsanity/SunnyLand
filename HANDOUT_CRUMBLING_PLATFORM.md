# Handout 2: Build a Crumbling Platform

In this handout you will build a platform that breaks apart a moment after the
player steps on it. Stand still too long and it drops out from under you. It is a
classic platformer trap that forces players to keep moving.

This builds on the SunnyLand Student Guide and works nicely *after* Handout 1
(Moving Platform), but you can do it on its own.

**Time:** about 45–60 minutes. **Difficulty:** medium.

---

## 1. The idea (read this first)

Our crumbling platform needs to do three things:

1. **Notice** when the player lands on it.
2. **Wait** a short moment (with a little shake, as a warning).
3. **Disappear** so the player falls through. Then maybe come back later.

Here is the key design choice. This platform **never actually moves** — it just
shakes its picture a little, then vanishes. Because it does not move, the right
node for it is **`StaticBody2D`**, the normal "solid wall" node.

> **Wait, why not `AnimatableBody2D` like the moving platform?**
> Use `AnimatableBody2D` only for things that truly *move* around the level. This
> one stays put, so `StaticBody2D` is the correct, simpler choice. Picking the
> right node for the job is a real game-dev skill — knowing the difference is the
> point of doing both handouts.

To **notice** the player, a `StaticBody2D` cannot do that by itself. So we add a
small **`Area2D`** sensor on top. An `Area2D` is a trigger zone: it does not block
anything, it just sends a message ("a body entered me!") that our code listens for.
This is the same trick the `Goal` flag and the `Killbox` use in this game.

---

## 2. Build the scene

1. In the FileSystem panel, right-click the `interactable` folder → **New Scene**.
2. Click **Other Node** → **`StaticBody2D`**. Rename the root `CrumblingPlatform`.
3. Add the solid part: right-click `CrumblingPlatform` → **Add Child Node** →
   **`CollisionShape2D`**. Give it a **New RectangleShape2D** and size it to a wide,
   flat platform.
4. Add the art: right-click `CrumblingPlatform` → **Add Child Node** →
   **`Sprite2D`**. Set its **Texture** to a platform image from `Assets/` and line
   it up on top of the rectangle.
5. Add the sensor: right-click `CrumblingPlatform` → **Add Child Node** →
   **`Area2D`**. Rename it `Detector`.
6. Give the `Detector` a shape: right-click `Detector` → **Add Child Node** →
   **`CollisionShape2D`**. Give it a **New RectangleShape2D**. Make it the same
   width as the platform but **thin**, and slide it up so it sits just above the
   platform's surface — that is the spot the player's feet will touch.
7. Save as `interactable/crumbling_platform.tscn`.

Your scene tree should look like this:

```
CrumblingPlatform         (StaticBody2D)
├── CollisionShape2D       (the solid part the player stands on)
├── Sprite2D               (the picture)
└── Detector               (Area2D — senses the player)
    └── CollisionShape2D    (thin zone on top of the platform)
```

---

## 3. Set the collision layers

Two nodes need layer settings here. Take it slow — this is the part people get
wrong.

**The platform body** (`CrumblingPlatform`) — so the player can stand on it:

1. Click `CrumblingPlatform`.
2. In the Inspector → **Collision**: under **Layer**, turn on **only** `world`
   (the first box). Turn **Mask** all the way off.

**The sensor** (`Detector`) — so it can feel the player touch it:

1. Click `Detector`.
2. In the Inspector → **Collision**: turn **Layer** all the way off. Under
   **Mask**, turn on **only** the second box (`player_collision`).

> Think of it like this: the **Mask** is what a node *looks for*. The detector
> looks for the player, so its Mask has `player_collision` turned on.

---

## 4. Connect the sensor to your code

We want our script to run the moment the player enters the `Detector`. Nodes
announce things with **signals**; we will listen for the `body_entered` signal.

1. First attach the script (so there is somewhere to connect to). Click
   `CrumblingPlatform`, click **Attach Script**, save it as
   `interactable/crumbling_platform.gd`, and paste the code from section 5 below.
2. Click the **`Detector`** node.
3. Click the **Node** tab (top-right, next to Inspector). You will see a list of
   signals.
4. Double-click **`body_entered`**.
5. In the pop-up, pick the `CrumblingPlatform` node (the one with the script),
   leave the method name as `_on_detector_body_entered`, and click **Connect**.

---

## 5. Add the script

Paste this into `interactable/crumbling_platform.gd`:

```gdscript
extends StaticBody2D

# A platform that breaks a moment after the player steps on it, then comes back.
# It never moves, so it is a StaticBody2D. (Use AnimatableBody2D only for
# platforms that actually move around — see the Moving Platform handout.)

# How long after the player lands before it falls away.
@export var warning_time := 0.6
# How long it stays gone before returning. Set to 0 to make it gone for good.
@export var respawn_time := 3.0

# Stops the platform from crumbling twice at once.
var crumbling := false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D


# Runs when the player steps into the Detector zone (we connected this in step 4).
func _on_detector_body_entered(body: Node2D) -> void:
	if body is Player and not crumbling:
		crumble()


func crumble() -> void:
	crumbling = true

	# Shake the picture (only the picture, not the solid part) as a warning.
	var origin := sprite.position
	var shake := create_tween().set_loops()
	shake.tween_property(sprite, "position", origin + Vector2(1, 0), 0.05)
	shake.tween_property(sprite, "position", origin - Vector2(1, 0), 0.05)

	# Wait for the warning, then stop the shake and snap the picture back.
	await get_tree().create_timer(warning_time).timeout
	shake.kill()
	sprite.position = origin

	# Turn the platform off so the player falls through.
	# set_deferred waits until the physics engine is free. If you flip the
	# shape off directly, Godot complains about changing collision mid-check.
	collision_shape.set_deferred("disabled", true)
	sprite.visible = false

	# Come back after a rest (unless respawn_time is 0).
	if respawn_time > 0.0:
		await get_tree().create_timer(respawn_time).timeout
		collision_shape.set_deferred("disabled", false)
		sprite.visible = true
		crumbling = false
```

> **The one tricky line.** `set_deferred("disabled", true)` is how we turn the
> collision off *safely*. The physics engine is often busy checking collisions at
> the exact moment the player lands. Changing a shape right then makes Godot throw
> an error. `set_deferred` politely says "do this as soon as you're free," which
> fixes it. Remember this trick — you will hit it again any time you turn collision
> on or off.

---

## 6. Put it in a level and test

1. Open a level in `world/` and drag in `interactable/crumbling_platform.tscn`.
2. Place it over a pit, or as one step in a row of platforms.
3. Press **F5**. Stand on it: it should shake, then drop you. If `respawn_time` is
   above 0, it returns after a few seconds.

---

## 7. Knobs you can turn

| Value | What it does | Try this |
|-------|--------------|----------|
| `warning_time` | Seconds you get before it breaks | `0.25` for cruel, `1.0` for kind |
| `respawn_time` | Seconds until it comes back (`0` = gone forever) | `0` over a deadly pit |

---

## 8. Challenges (try these once it works)

1. **Bridge of doom:** line up five crumbling platforms across a wide pit with
   short `warning_time`. The player has to run across without stopping.
2. **One-way trip:** set `respawn_time` to `0` so a platform never returns. Now the
   level can only be crossed once per life.
3. **Combo (needs Handout 1):** put a crumbling platform as the *only* way to reach
   a moving platform. Miss the timing and you start over.
4. **Make it louder (harder):** add an `AudioStreamPlayer2D` child and play a
   cracking sound at the start of `crumble()`. Look at how other scenes play
   sounds for an example.

---

## 9. If something breaks

- **Nothing happens when I stand on it.** The signal is not connected, or the
  detector's layers are wrong. Redo section 3 (Detector **Mask** = `player_collision`)
  and section 4 (connect `body_entered` to `_on_detector_body_entered`).
- **Red error mentioning "flushing queries" or "can't change."** You turned the
  collision off without `set_deferred`. Use the line exactly as written in section 5.
- **It breaks the instant the level loads.** Your `Detector` zone is too big or too
  low and is touching the player's start, or another body. Make the zone thin and
  sitting just on top of the platform.
- **Player falls through even before it crumbles.** The platform body's layer is
  wrong — its **Layer** must have `world` on (section 3).

---

### For the teacher / further reading

- Godot docs, `Area2D` (the sensor / trigger pattern): used here the same way the
  project's `Goal` and `Killbox` use it.
- Godot docs, `StaticBody2D` vs `AnimatableBody2D` — choosing static for things
  that don't move: <https://docs.godotengine.org/en/stable/classes/class_animatablebody2d.html>
- The `set_deferred` gotcha when toggling collision shapes is a well-known Godot
  pitfall; teaching it here saves a lot of confusion later.
