# Original Mission/Objective Ideas — Not Scheduled, Reference Only

These are original ideas for The Glitch / The Basement objectives, inspired by
the *staged, escalating objective* and *signature mechanic* principles in
[`pinball_fantasies_analysis.md`](pinball_fantasies_analysis.md). Nothing here
is copied from any existing pinball game's specific missions — these are new
names/mechanics for our own themes.

Per CLAUDE.md, this is idea-capture only. None of this is scheduled — MVP scope
for The Glitch is still whatever's locked in GDD §3, and this doc doesn't
change that. Treat it as a backlog to draw from once `core/objectives/` exists
and The Glitch's `objectives.json` is being authored.

## The Glitch (neon/synthwave hacking theme)

- **"Patch the Exploit"** — hit three specific "vulnerability" targets in any
  order within a time window (lit on hit) to open a ramp lock; completing it
  starts a short multiball ("Breach Mode") with altered scoring.
- **"Firewall Loop"** — repeatedly loop the same ramp N times without draining
  to build a jackpot value; a bumper hit while the loop is "hot" drains
  progress (risk/reward, mirrors the combo principle without copying a
  specific existing mechanic).
- **Escalating combo meter** — consecutive ramp/target hits within a short
  window build a score multiplier that resets on drain or long idle; purely a
  scoring-layer idea, not a physical objective, cheap to implement once base
  scoring exists.

## The Basement (Phase 2, not scheduled yet)

- Placeholder only — per CLAUDE.md, Basement content shouldn't be designed in
  detail until Phase 2 is reached; noting here only so the idea isn't lost:
  a "found object" theme could support a similar staged-lock mechanic reskinned
  around discovering/assembling something, without reusing Glitch's specific
  ramp-loop mechanic verbatim (each table should feel mechanically distinct,
  per the "one signature mechanic per table" principle).

## Explicitly not doing

- Not naming these after or matching structure of any specific existing game's
  named missions/modes.
- Not locking any of this into `objectives.json` schema decisions yet — that's
  a §11/Phase-1-implementation decision, not something this idea doc should
  presume.
