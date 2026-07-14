# The Glitch — Rendering/Material Reference Notes

Reference only — **not a build plan**. Captured from the designer's notes on
how The Glitch could look, written in 3D terms (`Node3D`/`MeshInstance3D`/
`WorldEnvironment`). Confirmed with the designer (2026-07-14): the project
stays 2D (`RigidBody2D`, locked per GDD §5.1) — the §10a physics feel and
the §10b mobile performance gate were both built and passed in 2D, and a
real 3D rebuild would throw both out. This doc exists so the *visual ideas*
aren't lost, translated to what they'd actually map to in our 2D pipeline.

## Original notes (3D terms, as written)

- **Scene root**: table as one `Node3D` root, sub-nodes per system (table
  body, ramps/lanes as separate meshes, ball as `RigidBody3D`, lights,
  camera, UI/fx as their own nodes).
- **Table geometry**: dark, slightly metallic `StandardMaterial3D` for the
  playfield (low roughness for reflections, faint neon emission lines along
  rails/lanes). Walls/rails as boxes/curved meshes with emissive neon edges
  (cyan/magenta), slightly metallic. Ramps/orbits as curved meshes with a
  glass-like material (high specular, some transparency, emissive edge
  lines that light up as the ball passes).
- **The Glitch Core**: `Node3D` root, polyhedron/hologram mesh, collision
  shape, `OmniLight3D` inside for glow. Custom shader material: UV-warping
  (glitch), emissive color shifts (red = corrupted, green = stable), some
  transparency for a hologram feel.
- **Targets/bumpers/drop targets**: static bodies with small meshes,
  emissive symbols that change color and trigger a glitch animation on hit.
  Bumpers: `Area3D` trigger + `GPUParticles3D` spraying "sprite fragments."
  Drop targets: fall animation + a "digital crack" decal/mesh.
- **Ball**: `RigidBody3D`, high-gloss metal material with reflections (via
  reflection probes), a faint emissive "data trail" during special modes.
- **Lighting/mood**: `WorldEnvironment` with HDR + bloom + SSAO,
  `DirectionalLight3D` for weak key light, `OmniLight3D` at the Core,
  `SpotLight3D` over ramps/targets, volumetric fog with spotlight volumetric
  energy for light cones over the table.
- **Camera/UI**: `Camera3D` angled down over the table. Holographic panels
  as separate transparent-emissive meshes; a "Debug Terminal" as a small
  mesh + `ViewportTexture` for text/graphics.
- **Post-processing**: bloom for neon glow, synthwave color grading
  (purple/blue tones), screen-space glitch shader overlay on mode
  start/multiball/system failure events.

## 2D translation guide

What each 3D idea maps to in our actual (2D, `GL Compatibility`) pipeline —
this is the list to actually work from when building table art later.

| 3D idea | 2D equivalent in this project |
|---|---|
| `WorldEnvironment` bloom | Not available in GL Compatibility (confirmed during §10b) — fake glow via additive-blended (`blend_mode = BLEND_MODE_ADD`) sprites, same technique already used in `spike_10b/performance_spike.tscn` for the bumper/pivot glow blobs. |
| `OmniLight3D`/`SpotLight3D`, volumetric fog | `PointLight2D` (already used in the spike scene) for dynamic lights; a soft radial-gradient sprite under a light can fake a volumetric "cone" cheaply. |
| Emissive neon materials on 3D meshes | `Polygon2D`/`Sprite2D` with bright flat colors + an additive glow layer behind/around them, same pattern as the bumper and flipper-pivot bolts already built. |
| Reflective/glossy ball material, reflection probes | Not physically reflective in 2D — fake with a static highlight/gradient baked into the ball's sprite, or a subtle animated shine overlay. |
| Glitch shader (UV-warping, screen-space) | Directly portable — `spike_10b/glitch_screen.gdshader` (`SCREEN_TEXTURE` RGB-split) already does this in `canvas_item` shader form and was verified working. |
| Holographic floating UI panels | `Control`/`CanvasLayer` UI with a semi-transparent, emissive-styled theme — genuinely 2D-native, no translation needed. |
| GPUParticles3D fragment sprays | `CPUParticles2D`/`GPUParticles2D` — already used for the bumper/pivot particle bursts in the spike scene. |
| Camera3D angled over the table | `Camera2D` (already in use) — the "angled" feel has to come from art/perspective baked into sprites, not an actual 3D camera tilt. |
| Curved glass ramp meshes | 2D polygon/line-based ramp geometry (as already built for the §10a ramp) with a semi-transparent tint and an animated emissive edge (shader or animated `Polygon2D` outline). |

## Open question carried over from the theme description

One reference image in the mood board leaned classic vaporwave (palm
trees, sun-grid horizon) rather than "modern, not retro" — still unresolved
whether any of that palette/mood is wanted. See
[`the_glitch_table_layout.md`](the_glitch_table_layout.md) for the full
layout this rendering approach applies to, and its scope note on what's
vertical-slice vs. backlog.
