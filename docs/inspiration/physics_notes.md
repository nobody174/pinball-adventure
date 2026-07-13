# Physics Feel Notes (inspiration only)

Principle-level notes on ball/flipper feel to guide §10a tuning
(`core/physics/ball.gd`, `core/physics/flipper.gd`). Not derived from the
original game's code or data — these are general pinball-feel heuristics.

## Flippers

- Full rest-to-active rotation should complete in roughly 60-100ms of real
  time once a button is pressed — feels instant, not springy.
- Flipper should feel "solid": a ball hitting a flipper mid-swing gets flung
  with authority, not absorbed. If shots off the flipper tip feel weak or
  mushy, torque/restitution needs tuning before anything else.
- A held flipper should stay rock-steady at full extension — any visible jitter
  or drift while held (like the anchor/CoM drift bug we already hit and fixed)
  reads as "broken" immediately to a player, even before they consciously
  notice why.

## Ball

- Restitution should be high enough that bounces off bumpers/walls feel lively,
  but not so high that the ball becomes unpredictable or floaty.
- Fixed timestep + continuous collision detection matters most at the ball's
  highest speeds (off a strong flipper hit or a bumper) — that's where
  tunneling is most likely, and where it's most damaging to feel if it happens.
- Ball should feel like it has real mass: it should visibly compress the
  flipper's swing timing slightly (i.e., a flipper mid-swing when it meets the
  ball shouldn't snap through the ball unaffected) — a subtle cue that keeps
  the ball from feeling like a weightless prop.

## Nudge / tilt

- Nudge should impart a small, brief impulse to the ball (and ideally a slight
  camera shake) — big enough to rescue a ball from a bad bounce occasionally,
  small enough that it's not a substitute for good flipper play.
- Tilt (locking out flippers / draining the ball) should only trigger after
  repeated or excessive nudging, not a single tap — punishing accidental single
  nudges kills the tool's usefulness.

## Open questions to resolve during playtesting

- Current `flipper.gd` uses a proportional torque controller
  (`angle_diff * torque_strength`) with no damping term — worth checking
  whether it overshoots/oscillates at high `torque_strength` values, since a
  pure P-controller with no damping can ring.
- No tilt/nudge penalty system exists yet in `core/physics/` — GDD mentions
  nudge but tilt consequences aren't implemented; flag as a small gap once
  §10a feel is otherwise locked.
