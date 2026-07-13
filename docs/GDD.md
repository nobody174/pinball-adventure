# Pinball Adventure — Game Design Document (Starting Draft)

Status: living discussion draft. Scope is deliberately narrow for v1; everything else is parked for later phases.

Design inspiration notes (principle-level, not sourced from any original code/assets): [`inspiration/pinball_fantasies_analysis.md`](inspiration/pinball_fantasies_analysis.md), [`inspiration/physics_notes.md`](inspiration/physics_notes.md), [`inspiration/mission_ideas.md`](inspiration/mission_ideas.md).

---

## 1. Vision

A modern digital pinball game that plays like an adventure: single tables that feel great to play on their own, wrapped in objective-driven progression, with replayability driven by mastering a table and (eventually) comparing scores with friends. Cross-platform from day one — desktop and mobile, with UI and controls that scale to both.

The long-term ambition (multiple themes, theme-evolution mechanics, global leaderboards, cosmetics, missions) is real and worth keeping in view, but none of it is built until the foundation — one excellent table — proves the core loop is fun.

**Guiding principle:** ship the smallest version that is fun, then turn every new table into a "content pack" that plugs into a stable framework, rather than hand-building each table's systems from scratch.

**Creative reference point: Pinball Fantasies (1992).** The inspiration isn't just the physics — it's that every table felt like a handcrafted world with its own personality, visuals, sound, and sense of place, not just a playfield with a skin swapped on. This is a core design pillar, not a nice-to-have: tables should feel explored, not just played. It directly shapes the technical requirements in §5 — atmosphere (lighting, animation, particles, layered audio) needs to be a supported production path, not custom tooling the team has to build.

**Critical path priority — locked order.** Visual identity is a pillar, not the top priority. If these ever compete for time, this is the order that wins:

1. **Ball + flipper feel** — the single biggest determinant of whether this is a good pinball game at all. A beautiful table with mediocre physics dies quickly; a visually simple table with great physics is already fun.
2. **Table layout fun** — is the layout itself engaging to shoot, independent of theme.
3. **Performance stability** — the game must run smoothly on target hardware before it ships, glitch effects included.
4. **Visual identity** — the handcrafted-world pillar from above; matters enormously, but after the game underneath it is proven.
5. **Progression systems** — objectives, unlocks, meta-loop.
6. **Online competition** — leaderboards, friend groups, anti-cheat.

This ordering governs both the prototype plan (§10) and how tradeoffs get made if schedule pressure hits.

---

## 2. Core Gameplay Loop

1. Launch ball, play table using classic pinball mechanics (flippers, nudge, tilt, ramps, targets).
2. Complete objectives on the table (e.g., hit all targets, complete a ramp combo, reach a score threshold) to unlock the next stage of that table/theme.
3. Score is tracked locally; personal best is shown after each session.
4. Player replays the table to beat their own high score or finish remaining objectives.
5. (Later phases) Completing all objectives on a table unlocks the next table; completing a theme unlocks the next theme.

v1 loop is intentionally single-table: play → complete objectives → chase personal best. The theme-to-theme meta-loop is a v2+ layer added once the single-table loop is proven fun.

---

## 3. MVP Scope (v1)

**Locked MVP theme: "The Glitch."** A corrupted video game world — the ball repairs broken game code. Style: synthwave, neon colors, digital corruption, glitch effects. This gives the table a strong, contained visual identity that fits Godot's shader/lighting strengths (§5.1) without requiring the multi-stage evolution complexity of a theme like Arcade Evolution — a sensible first pick for proving the pipeline before attempting something more ambitious.

**In:**
- 1 fully polished pinball table, "The Glitch" theme
- Solid, hand-tuned physics (flippers, ball, ramps, bumpers, tilt/nudge)
- 3–5 objectives themed around the "repair corrupted areas / activate loops / restore systems" mechanics from the theme concept — e.g., hit a bank of corrupted targets to "repair" a section (visually resolving glitch effects to clean neon), complete a ramp loop to "activate" it, reach a score/combo threshold to "restore" a system and unlock a multiball or new ramp path. This is the "adventure" hook even within a single table — objectives should feel like progress against the corruption, not generic pinball goals with a skin on top
- Local high score, persisted per device
- A compact input-log replay system (records flipper/nudge inputs + timestamps, not video) — built now because it's foundational to both scoring integrity and any future "watch a replay" feature, and is much harder to retrofit later
- Responsive UI/controls that work on desktop (keyboard) and mobile (touch), including portrait/landscape scaling of the table view

**Explicitly out of v1** (see roadmap):
- Multiple themes/tables
- XP, missions, cosmetics, table modifiers, achievements, challenge modes
- Friend groups, online/global leaderboards
- Theme-evolution visuals (Arcade Evolution style)
- Boss events, character events

---

## 4. Feature Roadmap

**Phase 1 — MVP (single table, "The Glitch"):** as above. Goal: prove the core loop is fun and the physics feel good on both input types (touch + keyboard).

**Phase 2 — Framework validation (2nd table): "The Basement."** Locked as a deliberate opposite of The Glitch — physical vs. digital, warm nostalgic lighting vs. neon, object/prop-driven storytelling vs. shader-driven corruption, different table toys and objective types. Building a second Glitch-style table would only prove the architecture works for one visual language; The Basement is the harder, more informative test. Goal: prove adding tables doesn't require touching core code, and that the framework generalizes rather than having been implicitly built around Glitch's specific needs. This phase is as much a technical milestone as a content one.

**Phase 3 — Meta-progression:** theme completion unlocking next theme, basic XP, personal achievements. Still local-only, no server.

**Phase 4 — Social layer, stage 1:** friend groups with invite codes, private leaderboards. Requires server-side score submission and the replay-verification backend (see §7).

**Phase 5 — Social layer, stage 2:** global leaderboard, gated on replay verification being reliable and abuse-tested inside friend groups first.

**Phase 6 — Content expansion:** cosmetics, table modifiers, challenge modes, additional themes (Arcade Evolution, The Glitch, sitcom/drama themes, comic-inspired themes) — all built as content packs per the Phase 2 framework.

---

## 5. Technical Architecture Overview

### 5.1 Engine choice: Godot (recommended)

**Re-evaluated in light of the "handcrafted world per table" creative pillar** (Pinball Fantasies reference — see §1). The original comparison assumed relatively simple physics playfields; that's no longer the actual requirement. Every table needing strong visual/audio identity, atmosphere, and a sense of place changes what "engine fit" means.

| Option | Pros | Cons |
|---|---|---|
| **Godot (HTML5 + mobile export)** | Free; strong built-in 2D physics; built-in animation system, 2D lighting/shaders, particles, and audio bus tooling — all needed for per-table atmosphere; scene inheritance maps directly onto "table as content pack"; one codebase for web+mobile+desktop | Smaller ecosystem/asset store than Unity; HTML5 export performance on low-end mobile with lights/shaders/particles layered on physics is unproven and must be tested early |
| Unity | Comparably mature 2D/lighting/VFX tooling, larger asset-store shader/VFX catalog, easier to hire for later, console path if ever wanted | Licensing/runtime overhead, heavier builds for web, steeper pipeline for a small team with no capability advantage for this specific project |
| Browser-native (Matter.js/Box2D + Canvas/WebGL) | Zero install for players, full control over physics tuning | No built-in animation, lighting, particle, or audio tooling — a "handcrafted world per table" pillar means hand-building all of that yourself. Fine for a single simple table, but becomes a growing tooling-debt tax on every table after #1, working directly against the content-pack philosophy |

**Verdict:** Godot. It's the only option where "every table is a handcrafted world" is a supported production path rather than infrastructure the team has to build from scratch, while still meeting the web+mobile+desktop requirement from one codebase at no license cost. Browser-native was a reasonable default for a bare physics playfield; it becomes a technical liability once atmosphere, animation, and per-table personality are core to the vision — not at table #1, but by tables #2–5, which is exactly where the content-pack philosophy is supposed to pay off. Unity's tooling is comparable but its extra cost/complexity isn't justified here without a console target or existing team fluency.

**Why it fits the vision specifically:** Godot's scene system supports inheritance — a base `PinballTable` scene defines shared physics, HUD hooks, and the objective-system interface, and each table's scene inherits from it, overriding visuals, layout, lighting, and unique mechanics. That's a direct technical match for the table manifest/package structure in §5.2 and §6 — new "worlds" are new scenes plugging into a stable base, not new engines of custom code.

**Locked risk to test, not assume:** Godot HTML5 export performance on low-end mobile browsers once 2D lights, shaders, and particles are layered on top of physics. This must be validated in the first prototype (§10), not discovered late.

### 5.2 High-level structure
- **Physics layer:** engine's built-in 2D rigid-body physics, fixed timestep to avoid tunneling at high ball speed. No custom physics engine.
- **Table package:** self-contained bundle per table — scene/level file, objective config, asset bundle (art/audio), metadata (theme id, unlock requirements). New tables = new package + manifest entry, no core engine changes.
- **Progression system:** data-driven, reads objective configs rather than hardcoded per-level logic.
- **Score/replay system:** local input-log recorder now; server-side replay validator added in Phase 4.
- **UI layer:** responsive canvas/viewport that scales table view and HUD for both portrait mobile and desktop aspect ratios.

---

## 6. Data Structure Ideas

- **Table manifest:** list of tables, each with id, theme id, unlock condition, asset path, objective config path.
- **Objective config (per table):** array of `{ id, type, target, reward }` — e.g., `{ type: "hit_targets", target: ["A","B","C"], reward: "unlock_ramp_2" }`.
- **Score record:** `{ playerId, tableId, score, inputLog, timestamp, clientVersion }` — inputLog is the compact replay used for later server verification.
- **Player progress:** `{ unlockedTables, completedObjectives, personalBests }`, stored locally in v1, synced to server from Phase 4 onward.
- **Theme registry (future):** groups tables into themes, tracks theme-completion state, visual/audio asset sets.

---

## 7. Leaderboards & Anti-Cheat

Honest starting position: a client-side game cannot be made cheat-proof — memory editors and trainers can always alter a value in RAM before it's sent anywhere. The realistic goal is cheat-resistant, not cheat-proof, calibrated to the stakes (private friend competition first, global leaderboard later and only once verification is solid).

- **v1 (local only):** no network trust needed, no anti-cheat required — it's a personal best, not a competition.
- **Phase 4 (friend groups):** submit score + input log to a server. Server re-simulates the input log through the same deterministic physics used client-side and checks it produces the claimed score. This catches memory-edited scores and most speed-hack/auto-flipper cases, because the score is derived from the verified replay, not trusted from the client. Add basic rate limiting and outlier flags (e.g., score N standard deviations above the field) for manual/automated review.
- **Phase 5 (global leaderboard):** only opened once replay verification has run against real friend-group traffic and abuse patterns are understood. A global board without this will be compromised quickly — it's a much bigger, more visible target than a private friend group.
- **Ongoing:** accept that a small percentage of determined cheaters may still get through; design the leaderboard UX (e.g., friend groups as the primary/default view, global as secondary) so cheating in a global board doesn't ruin the experience most players actually see.

---

## 8. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Physics/feel is subpar (the #1 pinball failure mode) | Spend disproportionate early time on flipper/ball tuning before any content work; get outside playtesters on table #1 before building table #2 |
| Scope creep from the long theme list | Roadmap gates every theme/feature behind Phase 2+ framework validation; nothing beyond MVP touches code until table #1 is validated as fun |
| Mobile performance (physics + rendering on low-end devices) | Test HTML5/mobile export early in Phase 1, not after the table is "done" |
| Engine choice regret | Decide before Phase 1 coding; treat the decision as a real fork worth deliberate comparison, not a default |
| Anti-cheat expectations mismatch | Be explicit with players (and yourself) that private friend-group leaderboards are the trustworthy default; global is opt-in and best-effort |
| Content-pack framework not actually reusable, or implicitly built around Glitch's specific needs | Phase 2 deliberately builds "The Basement" — visually and mechanically opposite to The Glitch — rather than a second digital/neon table, so the architecture (§11) is genuinely stress-tested, not just re-skinned |
| Glitch's effects-heavy style doesn't run acceptably on target hardware | Dedicated performance/effects spike (§10b) before production art, gated with a clear go/simplify decision |
| Visual polish quietly displaces physics/gameplay work under schedule pressure | Critical-path priority order locked in §1 (physics → layout → performance → visuals → progression → online) governs tradeoffs if time gets tight |

---

## 9. Development Milestones

1. **Physics-feel prototype (§10a):** single flipper pair + ball physics playable in-engine, tuned until it feels right, on both desktop and a touch device. No art, no objectives, no effects.
2. **Performance/effects spike (§10b):** throwaway technical prototype stress-testing Glitch-style visuals (glow, shaders, particles, lighting, multiple moving objects) running alongside the physics from step 1, on target mobile hardware. Decision gate before any production art is built.
3. **Vertical slice:** "The Glitch" table with real art/theme (glitch/neon visuals, synthwave audio direction), 1–2 repair/loop objectives, local high score.
4. **MVP release candidate:** full "The Glitch" table, all v1 objectives, replay/input-log recording, responsive UI polish on mobile + desktop.
5. **Phase 2 milestone:** "The Basement" built purely through the content-pack pipeline defined in §11, with zero changes to `core/` — validates the framework generalizes beyond Glitch's specific needs.
6. **Phase 4 milestone:** server-side replay verification + friend-group leaderboard live.

---

## 10. Prototype Plan — Two Sequential Spikes (immediate next steps)

Sequenced to match the critical-path priority in §1: physics feel first, performance/effects second, and neither one is skipped or merged, because they answer different questions and a failure in either should be caught before production art begins.

### 10a. Physics-feel prototype (priority 1 — do this first)

Goal: "does this feel like good pinball?" No visual identity, no theme, no effects.

- Bare-bones scene in Godot: two flippers, one ball, basic table boundary, one bumper, one ramp. Placeholder shapes only.
- Tune flipper torque/response, ball restitution/friction, nudge/tilt behavior, fixed-timestep physics to prevent tunneling at speed.
- Implement both control schemes immediately (keyboard for desktop, touch zones for mobile) — don't defer mobile input, since layout/scaling assumptions baked in early are expensive to unwind later.
- Playtested by you and ideally 1–2 outside people. Do not proceed to 10b until this feels genuinely fun — a performance win on bad physics is a wasted spike.

### 10b. Performance/effects spike (priority 3 — gates Glitch production art)

Goal: answer "can Godot run The Glitch's visual style smoothly on target hardware?" — not "does this look finished." This is a throwaway technical prototype, not vertical-slice art, and it runs on top of the physics prototype from 10a so ball simulation load is represented honestly, not tested in isolation.

Include only the risky elements, stress-tested together, not one at a time:
- Neon/glow effects (emissive materials / glow post-processing)
- Shader-based glitch effects (screen-space or material distortion)
- Particle effects (multiple emitters active at once)
- Animated background elements
- 2D lighting (Light2D, multiple dynamic lights)
- Multiple moving objects on-table simultaneously
- Ball physics from 10a running concurrently with all of the above

Test on actual target hardware, not just a dev machine — specifically a low/mid-range mobile browser via HTML5 export, since that's the tightest constraint given the desktop+mobile scaling requirement.

**Decision gate:**
- If frame rate and responsiveness hold up on target hardware → proceed to Glitch production art as planned.
- If not → simplify the visual approach (fewer simultaneous particle emitters, baked lighting instead of dynamic, reduced shader complexity) before committing to full production, not after.

---

## 11. Proposed Godot Project Architecture

The intent here is that "The Glitch" is built as the first instance of a reusable table framework, not a one-off — every system below is designed so The Basement (Phase 2) can plug into it with zero changes to core code, per the content-pack philosophy in §1/§5.2/§6.

```
res://
├── core/                          # Engine-agnostic-in-spirit systems; theme-independent
│   ├── physics/                   # Ball, flipper, plunger, tilt/nudge controllers
│   │   ├── ball.gd
│   │   ├── flipper.gd
│   │   └── tilt_nudge.gd
│   ├── table_base/                # Base PinballTable scene + script (see §5.1)
│   │   ├── pinball_table.tscn     # Inherited by every table's scene
│   │   └── pinball_table.gd       # Exposes hooks: register_objective(), on_ball_lost(), etc.
│   ├── objectives/                # Generic objective-evaluation engine, reads config not code
│   │   ├── objective_manager.gd
│   │   └── objective_types/       # hit_targets.gd, ramp_combo.gd, score_threshold.gd, etc.
│   ├── progression/                # Unlock state, personal bests, theme/table registry
│   │   ├── player_progress.gd
│   │   └── theme_registry.gd
│   ├── replay/                     # Input-log recorder/player (§6, §7)
│   │   └── input_log.gd
│   ├── ui/                         # Responsive HUD/menu framework, scales mobile/desktop
│   │   ├── hud.tscn
│   │   └── viewport_scaler.gd
│   └── net/                        # Placeholder now, real in Phase 4 — score submission,
│       └── (empty until Phase 4)   # friend-group/session client, kept isolated from core loop
│
├── tables/                         # One folder per table = one content pack
│   ├── the_glitch/
│   │   ├── the_glitch.tscn         # Inherits core/table_base/pinball_table.tscn
│   │   ├── the_glitch.gd           # Table-specific logic only (theme-specific objective wiring)
│   │   ├── objectives.json         # Data-driven objective config (§6) — repair/loop/restore
│   │   ├── art/                    # Glitch-specific sprites, shaders, glow materials
│   │   ├── fx/                     # Particle scenes, glitch shader resources
│   │   └── audio/                  # Synthwave music, glitch SFX
│   └── the_basement/                # Phase 2 — built identically, proves the pattern
│       ├── the_basement.tscn
│       ├── the_basement.gd
│       ├── objectives.json
│       ├── art/
│       ├── fx/
│       └── audio/
│
├── manifest/
│   └── tables.json                 # Table manifest (§6) — id, theme id, unlock condition, paths
│
└── autoload/                       # Singletons wiring the above together
    ├── GameState.gd                # Current table, session state
    ├── ProgressionService.gd       # Wraps core/progression, persists locally (Phase 1-3),
    │                                #   syncs to server from Phase 4
    └── AudioBus.gd                 # Per-table audio bus routing, ducking, mix
```

**Design notes tying this back to earlier sections:**
- **Core vs. table separation is the whole point:** nothing in `core/` should ever import from `tables/`. If building The Basement requires editing anything under `core/`, that's a signal the abstraction leaked and needs fixing before Phase 2 is considered validated (§4, §8).
- **Objectives are data, not code** (`objectives.json` per table) — new objective *types* go in `core/objectives/objective_types/` as reusable building blocks (e.g., `hit_targets`, `ramp_combo`), but each table only configures which types it uses and with what targets/rewards. The Glitch's "repair/loop/restore" framing is just naming applied to generic types (`hit_targets` → "repair," `ramp_combo` → "activate loop," `score_threshold` → "restore").
- **Effects (`fx/`) live inside each table's folder, not core** — this keeps The Glitch's shader/particle-heavy approach from becoming an assumption baked into the base framework, which matters given The Basement is deliberately effects-light and lighting-driven instead.
- **`net/` is scaffolded but empty** until Phase 4 — placing the folder now (rather than inventing it later) keeps the eventual server/leaderboard integration from becoming a bolt-on that touches core physics/objective code.
- **Autoloads are the seams** where Phase 4+ multiplayer and Phase 5 leaderboards attach — `ProgressionService` and a future `LeaderboardService` are the only places that need to know about network calls; gameplay code never does.

This structure is a proposal to validate empirically in Phase 2, not treat as final — if building The Basement reveals friction, that's exactly the signal the framework needs, and it's substantially cheaper to fix after 2 tables than after 10.

---

## Technology Decisions to Lock Before Development Begins

- **Engine: Godot** — locked based on the analysis in §5.1. Reopen only if the mobile-web atmosphere performance test in §10 fails badly enough to be a blocker.
- **Physics: Godot's built-in 2D physics**, fixed timestep — no custom physics engine.
- **Export targets from day one:** HTML5 (web) + mobile (touch) + desktop, tested in the first prototype, not bolted on after.
- **Table architecture:** base `PinballTable` scene with per-table scenes inheriting from it — locked as the mechanism for the content-pack philosophy (§5.2, §6).
- **Replay format:** input-log (flipper/nudge/timestamp), not video — locked now since it's foundational to both MVP scoring and Phase 4 server verification.
- **MVP theme: "The Glitch"** — locked. Synthwave/neon/glitch-corruption style; objectives built around repair/loop/restore mechanics (§3).
- **Phase 2 theme: "The Basement"** — locked. Chosen deliberately as the visual/mechanical opposite of The Glitch to properly stress-test the content-pack architecture (§4, §11).
- **Prototype sequencing: physics-feel (§10a) before performance/effects spike (§10b)** — locked, matching the critical-path priority order in §1. Neither is skipped or combined.
- **Critical-path priority order** — locked as stated in §1: ball/flipper feel → table layout fun → performance stability → visual identity → progression → online competition. Governs scope tradeoffs under schedule pressure.
- **Project architecture** — proposed structure in §11 adopted as the working plan, to be validated empirically once Phase 2 (The Basement) is built, per the note at the end of §11.

## Open Decisions Still Needing Your Input

- None blocking — all prior open items are now resolved. Next natural decision point is after the §10a physics prototype: whether the feel is good enough to proceed to §10b, or needs more tuning first.

---

## Appendix: Future Theme Bank (not scheduled, for reference only)

These were captured during early brainstorming as future content-pack candidates. None are scheduled — Phase 6 (§4) is where the roadmap revisits this list, and only after the framework has been validated against both The Glitch and The Basement.

- **Arcade Evolution** — timeline concept: 8-bit pixel art evolving into neon cyber/3D/glitch aesthetics as the player progresses; XP, character leveling, boss table event.
- **The Cook** — chemistry/laboratory-inspired table (tube ramps, lab equipment objectives).
- **The Syndicate** — crime-drama inspired (territory control, missions, hidden areas, safehouse ball locks).
- **The Sitcom Couch** — bright comedy style (apartment locations, coffee shop ramps, dialogue events).
- **The Stark Workshop** — industrial futuristic workshop (energy reactor toy, multiball activation, upgrade systems).
- **The Infinity Quest** — collect-six-stones concept, each with a unique challenge, final combined mode.
- **The Daily Bugle** — comic newspaper/superhero style (vertical ramps, web-swinging feel, fast movement).

Treat this list as a creative reference bank, not a commitment — every entry needs to pass through the same Phase 1/Phase 2 validation rigor before it becomes a real content pack.
