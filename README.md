# Pinball Adventure

A modern digital pinball game where every table is a handcrafted world (inspired by *Pinball Fantasies*, 1992), wrapped in objective-driven progression and personal-best chasing, built for desktop and mobile.

Full design and technical plan: [`docs/GDD.md`](docs/GDD.md)
Working rules for AI-assisted development: [`CLAUDE.md`](CLAUDE.md)

## Status

Pre-implementation. Next step is the physics-feel prototype (GDD §10a) — no code has been written yet.

## Stack

- **Engine:** Godot (GDScript), exporting to HTML5, mobile, and desktop from one codebase.
- **Physics:** Godot's built-in 2D rigid-body physics, fixed timestep.

## Structure

```
core/       — theme-independent systems: physics, table base, objectives, progression, replay, UI, net (placeholder)
tables/     — one folder per table = one content pack (the_glitch/, the_basement/)
manifest/   — table manifest (which tables exist, unlock conditions)
autoload/   — singletons wiring the above together
docs/       — GDD and design history
```

See GDD §11 for the full architecture rationale.

## Getting Started

1. Read `CLAUDE.md` and `docs/GDD.md` before making changes.
2. Current milestone: GDD §10a physics-feel prototype — flippers + ball + placeholder geometry only, no art, no theme.
3. Godot version: pin to a specific stable 4.x release once development starts (not yet decided — first commit should record the chosen version here).
