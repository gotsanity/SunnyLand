# SunnyLand Student Guide

Welcome. This is a small 2D platformer built in Godot 4.7. This guide helps you
start changing the game quickly, even if this is your first time. You do not
need to understand every file. Start by changing numbers, then move up to adding
your own pieces.

Read this once, then keep it open in a tab while you work.

## 1. Running the game

1. Open the project in the Godot editor (open `project.godot`).
2. Press F5 to play the whole game from the start.
3. Press F6 to play only the scene you currently have open.
4. Press the Stop button (or close the game window) when you are done.

Controls while playing:

| Action | Keys |
|--------|------|
| Move left / right | A and D, or the Left and Right arrows |
| Jump | Space |
| Shoot a fireball | Aim with the mouse, press Ctrl |
| Dash | Shift (only after you grab the strawberry) |

## 2. One important idea: up is negative

In Godot, the Y axis points down. That means a value that moves something UP is a
negative number. This is why the jump value is `-300` and not `300`. If you want a
higher jump, make the number MORE negative (for example `-360`). If you want a
weaker jump, make it closer to zero (for example `-200`).

## 3. Knobs you can turn (safe to experiment)

These are the most fun values to change. You change them in the editor, not in code:

1. Open the scene that has the thing you want to change.
2. Click the matching node in the Scene panel (top left).
3. Look at the Inspector panel (right side). The values are listed there.
4. Click a value, type a new one, and press Enter. Play with F5 to feel the change.

### Player (open `player/player.tscn`, click the Player node)

| Value | Starting number | What it does |
|-------|-----------------|--------------|
| SPEED | 110 | How fast you run |
| JUMP_VELOCITY | -300 | Jump strength (more negative jumps higher) |
| BOUNCE_HEIGHT | -400 | How high you bounce after stomping an enemy |
| COYOTE_TIME | 0.1 | Extra moment to still jump after stepping off a ledge |
| JUMP_BUFFER_TIME | 0.1 | Remembers a jump you press a little too early |
| DASH_SPEED | 260 | How fast the dash moves |
| DASH_DURATION | 0.15 | How long the dash lasts, in seconds |
| DASH_COOLDOWN | 0.5 | Wait time before you can dash again |
| respawn_timer_length | 3.0 | How long before you respawn after dying |

### Enemies (open an enemy scene in `enemies/`, click the root node)

| Value | What it does |
|-------|--------------|
| SPEED | How fast the enemy moves |
| JUMP_VELOCITY | How high hopping enemies jump |
| enable_flying | Checkbox. On means it ignores gravity and can fly |
| flip_anims | Checkbox. Flips the art if the enemy faces the wrong way |

Enemy behavior is split into State nodes (Idle, Follow, Hop, and so on) under the
enemy's StateMachine. Click a State node to find values like how far the enemy can
see you, how long it patrols, or how long it waits between attacks.

### Damage (open a file in `components/attacks/`, it opens in the Inspector)

These are Attack resources. Each one is just data:

| Value | What it does |
|-------|--------------|
| attack_damage | How much health it removes |
| knockback_force | How hard a hit shoves the victim back (try values near 150; 0 means no push) |
| team | "player" or "enemy". An attack only hurts the other team |

## 4. Which files can I edit?

Green light, change these freely:
- `player/player.gd` and the player values in the Inspector.
- Enemy values and the State node values in the Inspector.
- The Attack resources in `components/attacks/`.
- The level scenes in `world/`.

Yellow light, you can edit these but ask for help first:
- The component scripts in `components/` (HealthComponent, Hitbox, Hurtbox).
  Many enemies and the player depend on them, so a change here changes everything.

Red light, leave these alone unless your teacher says otherwise:
- `components/state_machine.gd` and `components/state.gd` (engine-like plumbing).
- Anything in the `addons/` folder (a third party tool).
- The `Assets/` folder (the raw art and sounds).

## 5. Recipes

### Add a new pickup (like a coin)

1. In the FileSystem panel, open `pickups/`. Right click an existing pickup folder
   (for example `gem`) and choose Duplicate. Give it a new name like `coin`.
2. Open your new scene and swap the sprite image for your own art.
3. Open the script. Every pickup starts with `extends Pickup`. The `Pickup` base
   class (in `pickups/pickup.gd`) already gives you `spawn_feedback()`, the little
   pop when collected. You only write what makes your pickup special inside
   `_on_body_entered(body)`. For example, give the player points or health.
4. Drag your new pickup scene into a level to place it.

### Add an enemy to a level

1. Open a level scene in `world/`.
2. In the FileSystem panel, find an enemy scene in `enemies/` (for example
   `enemies/frog/frog.tscn`).
3. Drag it into the level and move it where you want.
4. Press F5 and test. Tune its values in the Inspector until it feels right.

### Make your own enemy

1. Duplicate an existing enemy folder in `enemies/`, the same way as a pickup.
2. Change its art and its values.
3. To change how it behaves, look at which State nodes are under its StateMachine.
   Add or remove States to change the pattern (for example patrol, then chase).

### Add a new level and connect it

1. Duplicate a level in `world/` (for example `level_01`) and rename it.
2. Edit the tiles and place enemies and pickups.
3. The flag at the end of a level is a Goal. Click it and set its `next_scene`
   value to the level you want to load next. That is how levels link together.

## 6. Quick word list

- Node: one piece of a scene, like a sprite, a timer, or a collision shape.
- Scene: a group of nodes saved together, like the Player or a level.
- Instance: a copy of a scene placed inside another scene.
- Signal: a message a node sends out, like "I was hit" or "health changed".
  Other nodes can listen and react.
- Export variable: a value marked with `@export` so it shows in the Inspector and
  you can change it without touching code.
- Component: a small reusable node that does one job (health, taking hits, dealing
  hits) and gets attached to a player or enemy.
- Hurtbox: the area where a character GETS hurt (the receiver).
- Hitbox: the area that DEALS a hit (the attacker).
- State machine: a way to organize behavior into named States (Idle, Follow, Hop),
  where only one State runs at a time and States hand off to each other.

## 7. If something breaks

- Read the red text at the bottom of the editor. It usually names the file and the
  line number.
- Undo with Ctrl+Z. It works for both the editor and code.
- If the game will not start, make sure you did not rename a file that a scene was
  using. Put the name back, or update the scene to point at the new name.
- Still stuck, ask. Breaking things is part of learning. You can always undo.
