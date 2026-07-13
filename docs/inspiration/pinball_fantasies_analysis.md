# Design Analysis — Pinball Fantasies (1992, inspiration only)

This is a principle-level analysis of what made *Pinball Fantasies* (and its era of
Digital Illusions pinball games) work as games. It exists to inform original design
decisions for Pinball Adventure, not to be reproduced. No table layouts, art,
music, mission text, or code from the original are copied or referenced here —
see the "Avoid copying" list below and in the top-level project instructions.

## What made it work, at a principle level

**Ball feel over everything.** The ball reads as heavy and fast, but flippers are
snappy — near-zero perceived input lag between pressing a flipper button and the
flipper being at full extension. This is why our GDD locks "ball + flipper feel"
as priority 1 above all else (§1, CLAUDE.md Critical Path Priority).

**Each table has one identity-defining mechanic**, not a grab-bag of features.
A table is memorable because of a single central hook (a signature multiball
setup, a signature ramp loop, a signature "mode") that everything else supports,
rather than because it has the most features.

**Objectives escalate in stages, not as a flat checklist.** Completing part of
an objective visibly changes table state (a light turns on, a ramp becomes
"lit" for bonus, a lock opens) so the player has continuous legible feedback,
not just a hidden counter.

**Ramp combos reward skill, not luck.** Chaining shots (e.g., hitting the same
ramp repeatedly, or hitting a sequence of different targets quickly) pays out
disproportionately more than isolated hits. This creates a skill ceiling and a
reason to replay for better routes, not just higher raw score.

**Jackpots are a release valve, not a rate.** Value builds passively or through
specific shots, then pays out in one deliberate, telegraphed shot — the payout
moment is a distinct, telegraphed event (different sound, different lighting),
not just a bigger number ticking up.

**Multiball is a state change, not just "more balls."** It typically changes
scoring rules, lighting, and often music/intensity while active, so it reads as
a distinct mode the player enters and exits, not merely increased ball count.

**Tight, readable audio feedback.** Distinct short stingers per event type
(shot made, objective progressed, jackpot collected, ball lost) let a player
track game state by ear without looking away from the ball.

## Direct implications for Pinball Adventure

- Reinforces GDD §1 critical-path ordering — do not let table count or
  objective count grow before a single table's core loop feels good.
- Each table (The Glitch, The Basement, and any future table) should have one
  signature mechanic tied to its theme, decided early, not bolted on late.
- Objective system (`core/objectives/`) should support staged/visible progress
  states, not just binary complete/incomplete — worth checking this holds when
  the first objective types are implemented.
- Scoring should have a clear per-shot combo/streak concept distinct from flat
  point values, if not already covered by GDD §6 data structures.

See [`physics_notes.md`](physics_notes.md) for feel-specific notes and
[`mission_ideas.md`](mission_ideas.md) for original objective ideas for our
own tables.
