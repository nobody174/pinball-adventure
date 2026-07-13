# Progress Log

## Current Status
- Phase: 1 (MVP — "The Glitch")
- Active milestone: §10a Physics-feel prototype
- Gate status: not started

## Session Log
- 2026-07-13 (cont.): Second playtest round after fixes. Found and fixed two more real bugs: (1) flippers were spaced too close together (120px apart, 90px arms) so they physically overlapped at rest, and rest/active angles were swapped — flippers drooped further down when pressed instead of swinging up; fixed by widening pivot spacing (110/310) and correcting rest=droop-down/active=swing-up angle signs. (2) The drain/respawn logic wrote `position`/`linear_velocity` directly on the ball's RigidBody2D from `_physics_process`, which fights Godot's physics server transform sync — reproduced via a temporary headless debug probe (removed after fix): after one respawn the ball froze permanently with gravity no longer applying, confirmed in a scripted headless trace. Fixed by moving the teleport into `_integrate_forces()`, the correct hook for direct RigidBody2D state changes — reverified via the same headless trace, ball now falls/drains/respawns correctly on repeat. Also wired the previously-inert `launch_ball` input action to an actual impulse, and moved ball spawn off the bumper's dead-center vertical line. Playtested live: flippers now stay pinned, swing the right direction, ball loops indefinitely without getting stuck. Known gap (acceptable for §10a): no outlane/guide walls yet, so a missed flipper just drains — that's expected table-layout work, not core physics feel, and not yet in scope.
- §10a gate status: physics feel (flipper response, ball behavior, respawn loop) confirmed working end-to-end by the designer. Table layout (guides, ramp, additional bumpers) still open before calling §10a fully "done," per GDD — flagged for next session, not blocking further physics tuning.
- 2026-07-12: Reviewed CLAUDE.md + GDD.md, confirmed scope and understanding. Initialized private GitHub repo (github.com/nobody174/pinball-adventure). Installed Godot 4.7 (GDScript, not Mono) via winget. Built first §10a physics-feel prototype: `core/physics/physics_prototype.tscn` with two flippers, ball, boundary walls, one bumper, placeholder shapes only. Keyboard input (Left/Right arrows = flippers, Space = nudge, Up = launch) and touch zones both wired from the start. Validated headless (imports clean, runs without script errors) — not yet playtested for feel by a human. That's the next step.
- 2026-07-13: First real playtest, on-device. Found and fixed real bugs: (1) boundary walls and bumper had collision shapes but no visuals — added Polygon2D sprites so the table is actually visible; (2) flippers were free-floating RigidBody2D with no pivot constraint, so applying torque about their off-center collision shape caused them to translate away from their pivot instead of just rotating — fixed with a PinJoint2D anchoring each flipper to a fixed StaticBody2D at its pivot, plus forcing center_of_mass back to the pivot in `flipper.gd`. Also added: PD-style damping term to the flipper torque controller (pure P-control could ring at high torque — flagged in `docs/inspiration/physics_notes.md`), and a basic nudge impulse on the ball (cooldown-limited, no tilt lockout yet). Added `docs/inspiration/` (pinball_fantasies_analysis.md, physics_notes.md, mission_ideas.md) — principle-level design notes, not derived from original game code/assets, linked from GDD.md. Not yet re-playtested after these fixes — next step.

## How to Playtest (cabin / any machine)
1. `git pull` in the project folder.
2. Open Godot 4.7, "Import" this folder (project.godot), or just double-click project.godot if Godot is already associated.
3. Press Play (F5) — it should launch straight into the physics prototype scene.
4. Controls: Left/Right arrow keys = flippers, Space = nudge, Up = launch ball (not yet wired to a plunger, ball just starts near the top).
5. What to judge: does the flipper response feel snappy or sluggish? Does the ball ever tunnel through a flipper at speed? Does it feel "right" compared to real/other pinball games? Nothing else matters yet — no art, no objectives, no theme.

## Decisions/Deviations from GDD
(none yet — log anything here that extends or diverges from the locked GDD, per CLAUDE.md "Source of Truth")
