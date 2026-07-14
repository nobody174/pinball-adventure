# The Glitch — Full Layout Architecture Plan

Source: `docs/inspiration/layout/Gemini_Generated_Image_6x88hu6x88hu6x88.png` (AI-generated,
original — the design reference, not a trace of a real machine). The numeric
dimension annotations on the image ("3000 (1-1/16")" repeated inconsistently)
are decorative AI-generated text, not real engineering measurements — this
plan derives its own coordinate system from the table's proportions instead
of trusting those numbers.

This is a **plan**, not yet built. See the "Build Strategy" section at the
end for why, and the open decision that plan is blocked on.

## 1. Zone Breakdown (top to bottom)

| Zone | Approx. Y range (table-local) | Contents |
|---|---|---|
| Upper Playfield & Feature Zone | -1400 to -650 | Dual orbit loops (crossing X), 2x Saucer/Kickout (Capsule Lock L, Magnetic Accelerator Trap R), Captive Balls x2, Cyber-Ramps crossing, Rollunder Gate, Orbit Magnets x2, Multi-Level Gate, Skill-Shot Lane + Lights (far right), Locked Balls indicator |
| Middle Zone | -650 to -50 | Drop Target bank 1-4, Timed Gates, Spinners 1-3, Mini Target cluster 1-3, Mini-Flipper(s), VUK to Level 2, Mini Saucer Kickout, Pop Bumper Cluster (3), Standup Target bank A-E, Target B, Collapsing Bridge, Subway Entrance/Exit (VUK tunnel under the bumper cluster) |
| Lower Playfield | -50 to 700 (existing, unchanged) | Passive rubber posts, slingshots, main flippers, in/outlanes, drain, split shooter lane, mechanical ball elevator |

The lower playfield is **kept as-is** — it's the one part of this reference
that's structurally close to what's already built and tuned this session.
Everything from y≈-50 upward is new.

Total table height needed: roughly **2100px** (vs. the current 1350),
i.e. another ~750px of headroom above the existing top wall (y=-650),
extending it to **y≈-1400**. This is a second, larger instance of the same
kind of extension already done once this session — same method (extend
boundary, re-center camera/walls, shift CanvasLayer touch zones), scaled up.

## 2. Node Hierarchy (planned)

```
TheGlitch (existing root)
├── PhysicsPrototype (existing, unmodified — flippers/ball/lower playfield)
├── UpperZone (new Node2D)
│   ├── OrbitLoopLeft (new: chained-segment curved tube, see §3)
│   ├── OrbitLoopRight (mirrored)
│   ├── CyberRampCrossing (new: two curved ramps forming an X)
│   │   ├── CyberRampA (upper-left to lower-right)
│   │   └── CyberRampB (upper-right to lower-left)
│   ├── CapsuleLock (new: saucer.gd variant that feeds CaptiveBallLane)
│   ├── MagneticAcceleratorTrap (new primitive: magnet.gd)
│   ├── CaptiveBallLane (new primitive: captive_ball.gd, x2 balls)
│   ├── RollunderGate (reuse standup_target.gd, direct trigger)
│   ├── OrbitMagnetL / OrbitMagnetR (magnet.gd instances)
│   ├── MultiLevelGate (new primitive: timed_gate.gd or one-way gate)
│   └── SkillShotLane (StaticBody2D lane + standup_target.gd at the top)
├── MiddleZone (new Node2D)
│   ├── DropTargetBank (reuse drop_target.gd x4 — already exists)
│   ├── TimedGates (new primitive: timed_gate.gd)
│   ├── SpinnerBank (reuse spinner.gd x3 — already exists)
│   ├── MiniTargetCluster (reuse standup_target.gd x3, smaller scale)
│   ├── MiniFlipper (new: flipper.gd reused at smaller scale/shorter swing)
│   ├── VukToLevel2 (saucer.gd variant, ejects into UpperZone instead of same-level)
│   ├── MiniSaucerKickout (reuse saucer.gd)
│   ├── PopBumperCluster (already exists, reused as-is)
│   ├── StandupBankAtoE (reuse standup_target.gd x5, already have this pattern)
│   ├── CollapsingBridge (new primitive: collapsing_bridge.gd)
│   └── Subway (new primitive: subway_tunnel.gd — entrance + exit pair)
└── Feedback (existing, unmodified)
```

## 3. Curved Collision Geometry Plan

Godot 2D has no native curved collider. Two viable approaches, per element:

- **Chained straight segments** (already proven this session for the ramp
  cap and outlane wall): approximate a curve with N short `RectangleShape2D`
  segments, each rotated to match the local tangent angle. Good for gentle
  curves (orbits), cheap, easy to reason about clearance mathematically the
  same way the ramp/guide fixes were verified.
- **Hand-traced `CollisionPolygon2D`**: a single concave polygon tracing
  both edges of the tube. Better for tight/complex curves (the X-crossing),
  but harder to verify by hand — needs either a lot of manually computed
  points or an in-editor curve tool, and concave polygon collision in
  Godot 2D can behave unexpectedly at sharp concave corners (ball can catch
  on an inner corner) — this needs live playtesting to trust, not just math.

Plan: **orbit loops** = chained segments (12-16 segments per loop, ~15°
each, computed the same way the ramp cap's clearance was verified — derive
each segment's start/end from the target curve, check against every
existing element's actual collision extent before placing). **X-crossing
ramps** = hand-traced polygon per ramp, since the visual crossing point
needs the two ramps to physically pass over/under each other, which chained
segments can't do without an actual z-ordering / layer trick (see §5).

## 4. New Core Primitives Required

None of these exist yet. Each is a genuinely new reusable `core/physics/`
script, same tier of work as `saucer.gd`/`spinner.gd` built earlier this
session (each of those took a dedicated script + GUT test suite + careful
placement verification):

1. **`magnet.gd`** — Area2D applying a force toward its center while the
   ball is inside, for Orbit Magnets and the Magnetic Accelerator Trap.
   Needs tuning (real magnetic pinball elements are subtle — too strong
   and it reads as an invisible wall, too weak and it does nothing).
2. **`subway_tunnel.gd`** — paired entrance/exit; ball entering one end
   teleports to the other, following the same `_integrate_forces` +
   CCD-disable pattern as the debug teleport hook (that fix directly
   applies here — a live subway tunnel would hit the exact same bogus-sweep
   bug if built naively).
3. **`collapsing_bridge.gd`** — a platform that's solid until triggered,
   then briefly disables its collision (ball falls through to a lower
   path), then resets. State machine + timer.
4. **`timed_gate.gd`** — one-way or timed-open gate; needs a
   `OneWayCollision2D`-style setup (Godot supports one-way collision via
   `CollisionShape2D.one_way_collision`) plus a timer for the "timed" part.
5. **`captive_ball.gd`** — a ball confined to a short lane, hit by the main
   ball to score, per real captive-ball mechanics — different enough from
   the main `ball.gd` (no drain/respawn logic, constrained travel) that it
   likely wants its own lightweight script rather than reusing `ball.gd`.
6. **Mini-flipper** — can reuse `flipper.gd` directly with different
   `@export` tuning (shorter swing distance, smaller collision) — no new
   script needed, verified reusable as-is.
7. **Multi-level / "Level 2"** — 2D has no real depth. The standard trick is
   `z_index` layering plus a visual/collision swap when the ball enters a
   VUK that logically "changes level" (freeze the real ball, spawn/track a
   separate visual representation on the level-2 layer, physically the ball
   is just relocated to different world-space coordinates that represent
   "level 2" — e.g., a physically separate area of the table reserved for
   level-2 content, dressed to look elevated). This needs an explicit
   design decision: is "Level 2" a real separate physical zone with its own
   coordinates, or a cosmetic overlay on existing space? Blocked on that
   choice before implementation.

## 5. Implementation Order (if/when building starts)

Dependency-ordered, each stage independently testable before the next:

1. Extend table height (~750px more headroom) — mechanical, same method as
   the existing extension, lowest risk.
2. Mini-flipper (reuses existing script, fastest real validation of "does
   reusing flipper.gd at small scale feel right").
3. Drop/standup/spinner banks in the new zone (pure reuse of existing,
   already-tested scripts — no new primitives, just placement).
4. `magnet.gd` (new, self-contained, testable in isolation).
5. `timed_gate.gd` (new, self-contained).
6. `collapsing_bridge.gd` (new, self-contained).
7. `subway_tunnel.gd` (new — highest physics risk given the CCD-teleport
   lesson from earlier this session, wants the most careful testing).
8. `captive_ball.gd` (new).
9. Orbit loops (chained-segment curves — the ramp/loop precedent says this
   alone could take several playtest rounds).
10. X-crossing cyber-ramps + Level 2 resolution (highest complexity,
    depends on the Level 2 design decision above).

## 6. GDScript Scaffolding

Interface-level stubs only (signatures + intent) for the new primitives —
not full implementations, pending the build-strategy decision below.

```gdscript
# core/physics/magnet.gd
extends Area2D
signal activated
@export var pull_strength: float = 300.0
@export var active_duration_seconds: float = 0.4
# Applies a central force toward global_position to bodies inside while
# active; tables trigger activation (e.g. on a target hit) rather than
# this being always-on, matching how real playfield magnets are cued.

# core/physics/timed_gate.gd
extends StaticBody2D
signal opened
signal closed
@export var open_duration_seconds: float = 1.5
# Toggles a CollisionShape2D's `disabled` flag on a timer or external
# trigger; one-way variant sets one_way_collision = true on the shape.

# core/physics/collapsing_bridge.gd
extends StaticBody2D
signal collapsed
signal reset
@export var collapse_duration_seconds: float = 2.0
# Disables its CollisionShape2D on trigger, re-enables after the duration.

# core/physics/subway_tunnel.gd
extends Area2D
@export var exit_point: NodePath
@export var exit_velocity_direction: Vector2 = Vector2.DOWN
@export var exit_speed: float = 400.0
# On ball entry: body.request_teleport(exit_node.global_position,
# exit_velocity_direction.normalized() * exit_speed) -- reuses the exact
# teleport + CCD-disable machinery already built and tested in ball.gd.

# core/physics/captive_ball.gd
extends RigidBody2D
signal struck
# Confined-lane ball, no drain/respawn logic (unlike ball.gd) -- travel
# range enforced by lane wall geometry, not a bounds check.
```

## Build Strategy — open decision, not yet resolved

Every fix made to the existing ramp/loop system this session (the
RightGuide block, the drain gap, the CCD-teleport bug) was found only by
running a real ball through the geometry, not by checking the math alone.
This plan is roughly 8-10x the geometric complexity of that one ramp.
Building all of it in a single unverified pass risks stacking the same
class of invisible bug across every new subsystem simultaneously, with no
checkpoint to isolate which piece broke.

Two ways to proceed, designer's call:

- **Staged build** (recommended): work through the implementation order in
  §5, testing/playtesting each stage before starting the next, exactly like
  every other feature built this session. Slower to reach "the whole board
  exists" but each piece is verified working before the next depends on it.
- **Full blind build**: implement everything in §2-§4 in one pass with no
  intermediate verification, accepting that some (likely many, given the
  session's track record) pieces will have real bugs discovered only after
  the whole thing is built, requiring a large debugging pass at the end
  rather than spread across small ones.
