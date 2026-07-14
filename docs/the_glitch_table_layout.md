# The Glitch — Full Table Layout (Designer's Vision)

Captured from the designer's full table design pass (2026-07-14), written in
Norwegian and translated/organized here. This is the **complete vision** for
The Glitch as a finished table — not the vertical-slice scope. See
[Scope Note](#scope-note-not-a-vertical-slice) at the bottom for how this
maps onto GDD milestones, and
[`the_glitch_refs/`](inspiration/the_glitch_refs/) for the visual mood board
that informed it.

## Core concept

The table is a futuristic operating system that has crashed. A digital
parasite — **The Glitch** — is corrupting shader code, memory blocks, and
graphics modules. The ball is a diagnostic probe traveling through the
system, repairing it. Each mode is a system repair: recompiling shaders,
clearing the sprite cache, syncing the CPU clock, etc.

## Visual style — modern, not retro

Explicitly **not** 80s vaporwave/pixel art. Target references: *Tron:
Legacy*, *Ghostrunner*, *The Ascent* — high-resolution neon materials with
emissive light, glitch shaders with real UV-warping and pixel-stretching
(not retro 8-bit), floating holograms, volumetric light cones and bloom,
reflections on the ball itself showing the glitch effects around it.

One flagged tension from the reference mood board: one reference image
leans classic vaporwave (palm trees, sun-grid horizon) rather than the
"modern, not retro" direction stated elsewhere — worth deciding explicitly
whether any of that palette/mood is wanted, or to avoid the palm/sunset
motif entirely.

## Audio direction

Modern synthwave/darkwave with heavy basslines. Glitch effects that sound
"authentically digital," not retro 8-bit. Music that dynamically shifts as
the system is repaired. Voice lines: "SYSTEM FAILURE," "PATCH APPLIED,"
"CORE STABILIZED."

## Full table layout

### Upper area (backbox zone)

**RAM-Stack lanes** — three lanes, each a memory block:
- RAM A — bonus multipliers
- RAM B — activates modes
- RAM C — builds "System Stability"
- Visual: neon frames per lane, glitch effect on completing all three,
  holographic text hovering above.

**Mini-orbit** — a small loop feeding the ball down to the right flipper at
high speed.

**System Monitor (hologram)** — a floating panel showing system errors,
mode status, corrupted data "floating" around it.

### Mid area (main playfield)

**⭐ The Glitch Core (main toy)** — centered on the table. Rotating
polyhedron with a glitch shader, changes color based on system status,
locks balls for multiball, has 3 "data ports" to hit to activate modes.
This is the table's visual centerpiece.

**Shader Node Targets (left)** — three targets in a triangle formation; hit
in the right order to trigger **Shader Rebuild** mode. Lights flicker like
shaders compiling live; holographic symbols hover above.

**Sprite Cache Bumpers (right)** — three bumpers that spray digital
particles (fragmented sprites), build "Cache Load," and trigger **Sprite
Defrag** at max. Visual: particles that look like small hologram fragments,
neon ring around each bumper.

**CPU Clock Cycle lane (center)** — a fast, straight lane giving rhythmic
light pulses on hit, triggers **Clock Sync** mode, has an animated "clock
waveform" along the wall.

**VRAM Pipeline orbit (right)** — a large orbit sending the ball around the
whole table, builds "VRAM Throughput," usable for combos. Visual: light
tubes pulsing cyan as the ball passes, glitch effects when VRAM is
corrupted.

### Lower area (flipper zone)

**Firewall Breach drop targets** — four drop targets standing as a "digital
firewall." Hit in the right order to trigger **Firewall Breach** mode; a
"digital crack" animation plays behind them as they fall.

**Debug Terminal (mini-display)** — a small holographic display showing
error logs, system warnings, bonus info, mode progress. Reinforces the
modern high-tech feel.

**Slingshots** — neon slingshots with glitch effects; a brief "screen tear"
animation plays on activation; digital sound, not mechanical.

**Flippers** — two main flippers with neon edges, holographic symbols on
top, reflections of the surrounding glitch effects. Optional: a third
flipper on the left for advanced shots.

### Bonus areas

**Data Stream Ramp** — looks like a digital data stream, animated UV
scrolling, leads to a mini-playfield.

**Mini-playfield: "Corrupted Sector"** — a small upper playfield with 2
small flippers, 3 small targets, a glitch shader covering the whole area.

## Shot flow / logic

- Left flipper → Shader Nodes
- Left flipper → CPU Clock lane
- Left flipper → VRAM orbit
- Right flipper → RAM lanes (via mini-orbit)
- Right flipper → Glitch Core ports
- Right flipper → Firewall Breach targets

Intended to give good flow, fast loops, and clear goals.

## What makes this read as modern (not retro)

Neon + volumetric light; holograms floating above the table; glitch shaders
affecting the whole screen; reflections on the ball; particle effects that
read as expensive; UI panels floating in 3D space. Per the designer:
"this is not retro — this is premium digital pinball."

---

## Scope note: not a vertical slice

This is the **full-table vision**, useful as a north star and backlog, but
it is significantly larger than what GDD locks in as the next milestone.
Per GDD §9, the vertical slice is scoped to *"real art/theme, 1-2
repair/loop objectives, local high score"* — one or two objective loops, not
a complete system with 6+ subsystems and a mini-playfield with its own
flippers (mini-playfields with independent flippers are often a stretch
feature even on finished commercial tables).

Nothing here is being cut permanently — it's staying written down. But
building all of it at once would repeat the exact over-scoping pattern
CLAUDE.md calls out as this project's known failure mode. A proposed phased
breakdown (not yet agreed with the designer):

**Vertical slice (next milestone):**
- The Glitch Core, simplified to a single lock target (not 3 data ports yet)
- Shader Node Targets (3 targets, triangle formation) → Shader Rebuild mode
- Flipper neon edges + slingshot glitch effect (cheap, high visual payoff)
- This alone covers "1-2 repair/loop objectives" and exercises the core
  loop: shoot targets → trigger a mode → hit the Core → repeat.

**MVP release candidate (after vertical slice validates):**
- Sprite Cache Bumpers + Sprite Defrag mode
- CPU Clock Cycle lane + Clock Sync mode
- Debug Terminal display (ties into replay/scoring work already planned)

**Backlog / later (not scheduled):**
- RAM-Stack lanes + mini-orbit + System Monitor hologram
- VRAM Pipeline orbit
- Firewall Breach drop targets
- Data Stream Ramp + "Corrupted Sector" mini-playfield
- Third flipper
