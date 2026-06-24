# Handout 1: Build a Moving Platform

In this handout you will build a platform that slides back and forth on its own.
You can use it to carry the player across gaps, lift them up to high places, or
make a tricky jump that you have to time just right.

This builds on the SunnyLand Student Guide. If you have not read that yet, read
it first. Keep both open in tabs while you work.

**Time:** about 45–60 minutes. **Difficulty:** medium.

---

## 1. The idea (read this first)

A moving platform is *solid* — the player stands on top of it and rides along.
That means it cannot be just a picture. It has to be a real physics object so
the player can land on it and get carried.

Godot has a node made for exactly this job: **`AnimatableBody2D`**. The name is a
clue: it is a *body* (something solid the player can stand on) that you *animate*
(move with code). It is the right tool whenever you want something solid that you
move yourself — platforms, sliding doors, lifts.

> **Why not just move a Sprite?** A plain sprite is only a picture. The player
> would fall right through it. And a regular wall (`StaticBody2D`) is solid but is
> not built to move. `AnimatableBody2D` is the one node that is *both* solid *and*
> made to be moved. When you move it, it pushes and carries the player correctly.

The best way to move it is with a **Tween**. A tween is a little helper that
smoothly changes a value over time — here, the platform's position. We tell the
tween to slide the platform out, then back, then loop forever.

One important rule: the tween must run on the **physics step**, the same heartbeat
the player moves on. If it does not, the player will jitter or slide off. You turn
this on with one line, shown below. Don't worry about memorizing it — just copy it.

---

## 2. Build the scene

We will make this a reusable scene, just like a pickup or an enemy, so you can
drop copies into any level.

1. In the FileSystem panel, right-click the `interactable` folder → **New Scene**.
2. In the new scene, click **Other Node** and choose **`AnimatableBody2D`**. This
   is the root node. Rename it `MovingPlatform` (double-click the name).
3. Click `MovingPlatform`, then in the Inspector check that **Sync To Physics** is
   **On** (it usually is by default). This is what keeps the player riding smoothly.
4. Add the solid shape. Right-click `MovingPlatform` → **Add Child Node** →
   **`CollisionShape2D`**. In the Inspector, click the **Shape** dropdown and pick
   **New RectangleShape2D**. Then drag the orange handles to make a wide, flat
   rectangle — that is the part the player will stand on.
5. Add the art. Right-click `MovingPlatform` → **Add Child Node** → **`Sprite2D`**.
   In the Inspector, set its **Texture** to a platform-looking image from the
   `Assets/` folder (drag an image onto the Texture slot). Line the picture up so
   it sits on top of your rectangle shape.
6. Save the scene as `interactable/moving_platform.tscn`.

Your scene tree should look like this:

```
MovingPlatform        (AnimatableBody2D)
├── CollisionShape2D   (the solid part the player stands on)
└── Sprite2D           (the picture)
```

---

## 3. Set the collision layer (important!)

For the player to land on your platform, the platform has to be on the layer the
player bumps into. In this game that layer is called **world**.

1. Click `MovingPlatform`.
2. In the Inspector, open the **Collision** section.
3. Under **Layer**, turn on **only** the first box (`world`). Turn every other box
   off.
4. Under **Mask**, turn **everything off**. (The platform moves by code, so it does
   not need to sense anything.)

> If you skip this step the player will fall straight through the platform.

---

## 4. Add the script

1. Click `MovingPlatform`, then click the **Attach Script** button (the page icon
   with a `+` near the top of the Scene panel). Save it as
   `interactable/moving_platform.gd`.
2. Delete everything Godot put in the file, and type this in:

```gdscript
extends AnimatableBody2D

# A platform that slides back and forth on a loop.
# Because this is an AnimatableBody2D moved on the physics step, the player
# rides it automatically — the player's own movement code does the rest.

# How far and which way the platform travels from where you placed it.
# Remember from the Student Guide: up is negative!
#   Vector2(64, 0)  = slide right 64 pixels
#   Vector2(-64, 0) = slide left
#   Vector2(0, -64) = lift UP 64 pixels
@export var travel := Vector2(64, 0)

# Seconds for one full round trip (slide out AND come back).
@export var trip_time := 4.0

# We remember where the platform started so it can return there.
var start_position: Vector2


func _ready() -> void:
	start_position = position
	start_moving()


func start_moving() -> void:
	# Make a tween and tell it to run on the physics step, so the platform
	# stays in step with the player standing on it.
	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops()  # repeat forever

	# Slide out to the far point, then slide back. Each leg takes half the trip.
	tween.tween_property(self, "position", start_position + travel, trip_time / 2.0)
	tween.tween_property(self, "position", start_position, trip_time / 2.0)
```

3. Press **F6** to play just this scene. The platform should slide back and forth.
   (The player is not here yet, so you are just checking the motion.)

---

## 5. Put it in a level

1. Open a level in `world/` (for example `world/level_01/level_01.tscn`).
2. From the FileSystem panel, drag `interactable/moving_platform.tscn` into the
   level. Move it over a gap or under a high ledge.
3. Press **F5** and jump on it. The player should ride along with the platform.

---

## 6. Knobs you can turn

Click the platform in your level and change these in the Inspector. No code needed.

| Value | What it does | Try this |
|-------|--------------|----------|
| `travel` | How far and which way it moves | `(0, -96)` for a lift, `(120, 0)` for a long slide |
| `trip_time` | How many seconds for a full out-and-back | Smaller = faster and meaner |
| Sync To Physics | Keeps the player riding smoothly | Leave **On** |

Because `travel` is measured from wherever you drop the platform, you can place
several copies in one level and each one moves on its own.

---

## 7. Challenges (try these once it works)

1. **Elevator:** set `travel` to move only up, like `(0, -128)`, and use it to
   reach a high pickup.
2. **Gauntlet:** place three platforms moving up and down with *different*
   `trip_time` values so the timing is different on each one.
3. **The long haul:** make one slow platform with a big sideways `travel` that
   carries the player across a wide pit. Miss the timing and you fall.
4. **Diagonal (harder):** set `travel` to something like `(80, -80)` so it moves
   diagonally.

---

## 8. If something breaks

- **Player falls through the platform.** The collision layer is wrong. Redo
  section 3 — Layer must have **world** turned on.
- **Player jitters or slides off while riding.** Make sure **Sync To Physics** is
  On (section 2, step 3), and that your script has the
  `.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)` part.
- **Platform does not move.** Check that `travel` is not `(0, 0)`, and that
  `start_moving()` is called from `_ready()`.
- **Nothing is solid at all.** Make sure you have a `CollisionShape2D` with a real
  shape assigned (section 2, step 4), not an empty one.

---

### For the teacher / further reading

- Godot docs, `AnimatableBody2D` — the node made for moving solids:
  <https://docs.godotengine.org/en/stable/classes/class_animatablebody2d.html>
- Godot 4 Recipes, *Moving Platforms* (the tween-on-physics pattern this handout
  follows): <https://kidscancode.org/godot_recipes/4.x/2d/moving_platforms/index.html>
