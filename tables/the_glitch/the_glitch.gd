#
# Pinball Adventure
# Author:  nobody174 (nobodylearn174@gmail.com)
# Repo:    https://github.com/nobody174/pinball-adventure
# Patreon: https://www.patreon.com/c/Nobody174
# License: All rights reserved (c) 2026 nobody174
# "It's never too late to give up!"
#

extends PinballTable

## The Glitch — vertical slice. Table-specific wiring only: what "shader_a/
## b/c" mean and what happens when the objective completes. The objective
## system itself (core/objectives/) has no idea any of this exists.

const TABLE_ID := "the_glitch"

const GlitchZapScene := preload("res://tables/the_glitch/fx/glitch_zap.tscn")

const SHADER_A := "shader_a"
const SHADER_B := "shader_b"
const SHADER_C := "shader_c"

const CACHE_A := "cache_a"
const CACHE_B := "cache_b"
const CACHE_C := "cache_c"
const SPRITE_DEFRAG_THRESHOLD := 6

const FW_A := "fw_a"
const FW_B := "fw_b"
const FW_C := "fw_c"
const FW_D := "fw_d"

const VRAM_PIPELINE := "vram_pipeline"
const VRAM_THROUGHPUT_THRESHOLD := 4

const COMPILE_A := "compile_a"
const COMPILE_B := "compile_b"
const COMPILE_C := "compile_c"
const COMPILE_OVERCLOCK_THRESHOLD := 10

const BANK_1 := "bank_1"
const BANK_2 := "bank_2"
const BANK_3 := "bank_3"
const BANK_4 := "bank_4"
const BANK_5 := "bank_5"

const SAUCER_MAIN := "saucer_main"
const SAUCER_SECONDARY := "saucer_secondary"

const MINI_TARGET_1 := "mini_target_1"
const MINI_TARGET_2 := "mini_target_2"
const MINI_TARGET_3 := "mini_target_3"

const CAPTIVE_1 := "captive_1"
const CAPTIVE_2 := "captive_2"

const SHADER_TARGET_POINTS := 100
const CORE_CHARGED_HIT_POINTS := 1000
const CORE_UNCHARGED_HIT_POINTS := 50
const SLINGSHOT_POINTS := 25
const BUMPER_POINTS := 50
const CACHE_BUMPER_POINTS := 50
const SPRITE_DEFRAG_BONUS_POINTS := 750
const CLOCK_LANE_POINTS := 150
const FIREWALL_TARGET_POINTS := 100
const FIREWALL_BREACH_BONUS_POINTS := 1000
const VRAM_PIPELINE_PASS_POINTS := 75
const VRAM_THROUGHPUT_BONUS_POINTS := 600
const COMPILE_BUMPER_POINTS := 60
const COMPILE_OVERCLOCK_BONUS_POINTS := 800
const SPINNER_POINTS := 30
const STANDUP_BANK_TARGET_POINTS := 80
const STANDUP_BANK_BONUS_POINTS := 500
const ROLLOVER_GATE_POINTS := 40
const SAUCER_CAPTURE_POINTS := 150
const HIGH_SPEED_LOOP_POINTS := 120

## Reality Break: the Glitch Core's 3 "gates" (see rotating_toy.gd) are each
## raised by completing one major objective from a different zone -- one
## reason chosen per gate: shader_rebuild is the lower/mid-zone repair loop,
## firewall_breach is the mid-zone drop-target bank, captive_dual is the
## upper-zone lock. Raising all 3 is the wizard-mode-style readiness check;
## the actual reward (multiball) fires once, and both the Core's own gates
## and the underlying objectives reset so the whole climb can repeat.
const REALITY_BREAK_BALL_COUNT := 3
const REALITY_BREAK_LAUNCH_VELOCITY := Vector2(0, -1400)
const REALITY_BREAK_BONUS_POINTS := 2000
const SAUCER_DOUBLE_BONUS_POINTS := 900

const MINI_TARGET_POINTS := 60
const MINI_TARGET_CLUSTER_BONUS_POINTS := 700
const CAPTIVE_STRIKE_POINTS := 100
const CAPTIVE_DUAL_BONUS_POINTS := 1200
const ROLLUNDER_GATE_POINTS := 50
const VUK_LEVEL2_POINTS := 200
const MINI_SAUCER_KICKOUT_POINTS := 150
const CAPSULE_LOCK_POINTS := 175
const SKILL_SHOT_POINTS := 500
const CYBER_RAMP_POINTS := 250

const LEVEL2_DURATION_SECONDS := 15.0
const LEVEL2_SCORE_MULTIPLIER := 2

@onready var _feedback_label: Label = $Feedback/Label
@onready var _score_label: Label = $Feedback/ScoreLabel
@onready var _high_score_label: Label = $Feedback/HighScoreLabel
@onready var _debug_terminal: DebugTerminal = $Feedback/DebugTerminal
@onready var _glitch_core: Area2D = $GlitchCore

var _level2_active: bool = false

func _ready() -> void:
	super._ready()
	objectives.load_from_config([
		{
			"id": "shader_rebuild",
			"type": "hit_targets",
			"target_ids": [SHADER_A, SHADER_B, SHADER_C],
			"require_order": true,
		},
		{
			"id": "sprite_defrag",
			"type": "accumulate_hits",
			"target_ids": [CACHE_A, CACHE_B, CACHE_C],
			"threshold": SPRITE_DEFRAG_THRESHOLD,
		},
		{
			"id": "firewall_breach",
			"type": "hit_targets",
			"target_ids": [FW_A, FW_B, FW_C, FW_D],
			"require_order": false, ## Drop targets stay down once hit — order-sensitivity doesn't make sense here (see docs/PROGRESS.md).
		},
		{
			"id": "vram_throughput",
			"type": "accumulate_hits",
			"target_ids": [VRAM_PIPELINE],
			"threshold": VRAM_THROUGHPUT_THRESHOLD,
		},
		{
			"id": "compile_overclock",
			"type": "accumulate_hits",
			"target_ids": [COMPILE_A, COMPILE_B, COMPILE_C],
			"threshold": COMPILE_OVERCLOCK_THRESHOLD,
		},
		{
			"id": "standup_bank",
			"type": "hit_targets",
			"target_ids": [BANK_1, BANK_2, BANK_3, BANK_4, BANK_5],
			"require_order": false,
		},
		{
			"id": "saucer_double",
			"type": "hit_targets",
			"target_ids": [SAUCER_MAIN, SAUCER_SECONDARY],
			"require_order": false,
		},
		{
			"id": "mini_target_cluster",
			"type": "hit_targets",
			"target_ids": [MINI_TARGET_1, MINI_TARGET_2, MINI_TARGET_3],
			"require_order": false,
		},
		{
			"id": "captive_dual",
			"type": "hit_targets",
			"target_ids": [CAPTIVE_1, CAPTIVE_2],
			"require_order": false,
		},
	])
	objective_completed.connect(_on_objective_completed)
	objective_sequence_reset.connect(_on_objective_sequence_reset)

	wire_hit_group($ShaderNodeTargets.get_children(), SHADER_TARGET_POINTS,
		func(id: String) -> void: _debug_terminal.log_event("> shader node hit: %s" % id))

	var cache_kick_areas: Array = []
	for bumper in $SpriteCacheBumpers.get_children():
		cache_kick_areas.append(bumper.get_node("KickArea"))
	wire_hit_group(cache_kick_areas, CACHE_BUMPER_POINTS,
		func(id: String) -> void: _debug_terminal.log_event("> cache hit: %s" % id))

	wire_hit_group($FirewallBreach.get_children(), FIREWALL_TARGET_POINTS,
		func(id: String) -> void: _debug_terminal.log_event("> firewall target down: %s" % id))

	wire_hit_group([$VramPipeline], VRAM_PIPELINE_PASS_POINTS,
		func(id: String) -> void: _debug_terminal.log_event("> vram pipeline pass: %s" % id))

	var pop_bumper_kick_areas: Array = []
	for pop_bumper in $PopBumperCluster.get_children():
		pop_bumper_kick_areas.append(pop_bumper.get_node("KickArea"))
	wire_hit_group(pop_bumper_kick_areas, COMPILE_BUMPER_POINTS,
		func(id: String) -> void: _debug_terminal.log_event("> compile core hit: %s" % id))

	_glitch_core.hit_while_charged.connect(_on_core_hit_while_charged)
	_glitch_core.hit_while_uncharged.connect(func() -> void: GameState.add_score(CORE_UNCHARGED_HIT_POINTS))
	_glitch_core.all_gates_raised.connect(_on_reality_break_ready)
	$LeftSlingshot.kicked.connect(func() -> void: GameState.add_score(SLINGSHOT_POINTS))
	$RightSlingshot.kicked.connect(func() -> void: GameState.add_score(SLINGSHOT_POINTS))
	$PhysicsPrototype/Bumper/KickArea.kicked.connect(func() -> void: GameState.add_score(BUMPER_POINTS))
	$ClockLane.hit.connect(_on_clock_lane_hit)
	$RolloverGate.hit.connect(func(_id: String) -> void: GameState.add_score(ROLLOVER_GATE_POINTS))
	for saucer in [$Saucer, $Saucer2]:
		saucer.captured.connect(func(id: String) -> void:
			GameState.add_score(SAUCER_CAPTURE_POINTS)
			register_target_hit(id)
			_debug_terminal.log_event("> saucer captured ball: %s" % id))
		saucer.ejected.connect(func(id: String) -> void: _debug_terminal.log_event("> saucer ejected ball: %s" % id))
	$HighSpeedLoop.hit.connect(func(_id: String) -> void:
		GameState.add_score(HIGH_SPEED_LOOP_POINTS)
		_show_feedback("HIGH-SPEED LOOP", Color(1, 0.85, 0.2, 1)))
	$Spinner2.spun.connect(func(_id: String) -> void: GameState.add_score(SPINNER_POINTS))
	$Spinner.spun.connect(func(_id: String) -> void: GameState.add_score(SPINNER_POINTS))

	wire_hit_group($StandupBank.get_children(), STANDUP_BANK_TARGET_POINTS,
		func(id: String) -> void: _debug_terminal.log_event("> standup bank hit: %s" % id))

	## -- UpperZone (full-layout rebuild) wiring --
	var mid_zone := $UpperZone/MidZone
	var crossover_zone := $UpperZone/CrossoverZone
	var top_zone := $UpperZone/TopZone

	wire_hit_group(mid_zone.get_node("MiniTargets").get_children(), MINI_TARGET_POINTS,
		func(id: String) -> void: _debug_terminal.log_event("> mini target hit: %s" % id))

	for captive in [top_zone.get_node("CaptiveBall1"), top_zone.get_node("CaptiveBall2")]:
		captive.struck.connect(func(id: String) -> void:
			_award(CAPTIVE_STRIKE_POINTS)
			register_target_hit(id)
			_debug_terminal.log_event("> captive ball struck: %s" % id))

	crossover_zone.get_node("RollunderGate").hit.connect(func(_id: String) -> void:
		_award(ROLLUNDER_GATE_POINTS)
		crossover_zone.get_node("MultiLevelGate").trigger_open())

	mid_zone.get_node("VukToLevel2").captured.connect(func(_id: String) -> void:
		GameState.add_score(VUK_LEVEL2_POINTS)
		top_zone.get_node("MagneticAcceleratorTrap").activate()
		_start_level2_mode())

	mid_zone.get_node("MiniSaucerKickout").captured.connect(func(_id: String) -> void:
		GameState.add_score(MINI_SAUCER_KICKOUT_POINTS))

	top_zone.get_node("CapsuleLock").captured.connect(func(_id: String) -> void:
		GameState.add_score(CAPSULE_LOCK_POINTS))

	top_zone.get_node("SkillShotTarget").hit.connect(func(_id: String) -> void:
		GameState.add_score(SKILL_SHOT_POINTS)
		_show_feedback("SKILL SHOT", Color(1, 0.85, 0.2, 1)))

	crossover_zone.get_node("RampAEntrance").entered.connect(func(_id: String) -> void:
		_award(CYBER_RAMP_POINTS)
		_show_feedback("CYBER RAMP A", Color(0.2, 0.9, 1, 1)))
	crossover_zone.get_node("RampBEntrance").entered.connect(func(_id: String) -> void:
		_award(CYBER_RAMP_POINTS)
		_show_feedback("CYBER RAMP B", Color(1, 0.2, 0.7, 1)))

	register_ball($PhysicsPrototype/Ball)

	## Visual plunger: pulls back proportionally while charging (input now
	## bound to the Down arrow, not Up -- pulling a real plunger toward the
	## player is a pull-back/down motion, matching how launch_ball is now
	## mapped in project.godot), snaps back to rest the instant the ball
	## actually launches (charge resets to 0).
	##
	## The table's playable area was extended a modest 100px downward
	## (core/physics/physics_prototype.tscn -- side walls, camera's
	## max_camera_y, touch zones all updated together) to give the plunger a
	## real home to retract into -- a first attempt at 300px was much more
	## than a 40px rod animation actually needed and was scaled back down.
	## Earlier attempts at just widening the travel distance in place (with
	## no new space at all) failed because the rod's old rest position
	## (y=690) sat almost exactly on the camera's old visible-bottom-edge
	## (y=700), so any larger pull-back drove it off-screen regardless of
	## direction.
	const PLUNGER_REST_Y := 710.0
	const PLUNGER_MAX_PULLBACK := 40.0 ## Retracts *down*, away from the ball -- the physically correct direction.
	var plunger_tip_rest_color: Color = $PlungerTip.color
	var plunger_tip_charged_color := Color(1, 0.85, 0.2, 1)
	$PhysicsPrototype/Ball.launch_charge_changed.connect(func(charge_ratio: float) -> void:
		var pulled_y := PLUNGER_REST_Y + charge_ratio * PLUNGER_MAX_PULLBACK
		$PlungerRod.position.y = pulled_y
		$PlungerTip.position.y = pulled_y
		$PlungerTip.color = plunger_tip_charged_color if charge_ratio >= 1.0 else plunger_tip_rest_color)

	GameState.score_changed.connect(_on_score_changed)
	GameState.reset_score()
	_high_score_label.text = "HIGH SCORE: %d" % GameState.get_high_score(TABLE_ID)

func _on_score_changed(new_score: int) -> void:
	_score_label.text = "SCORE: %d" % new_score
	## No real "game over" concept yet in this prototype (the ball just
	## respawns indefinitely), so the high score is kept live-updated rather
	## than submitted at some end-of-game event that doesn't exist yet.
	if GameState.submit_score(TABLE_ID, new_score):
		_high_score_label.text = "HIGH SCORE: %d" % new_score

func _on_objective_completed(objective_id: String) -> void:
	if objective_id == "shader_rebuild":
		_show_feedback("SHADER REBUILD COMPLETE — CORE CHARGED", Color(1, 0.85, 0.2, 1))
		_glitch_core.charged = true
	elif objective_id == "sprite_defrag":
		GameState.add_score(SPRITE_DEFRAG_BONUS_POINTS)
		_show_feedback("SPRITE DEFRAG COMPLETE", Color(0.6, 0.2, 1, 1))
		objectives.get_objective("sprite_defrag").reset() ## Charge-style — repeats, unlike the one-shot shader sequence.
	elif objective_id == "firewall_breach":
		GameState.add_score(FIREWALL_BREACH_BONUS_POINTS)
		_show_feedback("FIREWALL BREACH COMPLETE", Color(1, 0.3, 0.3, 1))
		for drop_target in $FirewallBreach.get_children():
			drop_target.reset_target()
		objectives.get_objective("firewall_breach").reset()
		_glitch_core.raise_gate(1)
	elif objective_id == "vram_throughput":
		GameState.add_score(VRAM_THROUGHPUT_BONUS_POINTS)
		_show_feedback("VRAM THROUGHPUT MAXED", Color(0.2, 1, 0.9, 1))
		objectives.get_objective("vram_throughput").reset() ## Charge-style — repeats, same pattern as Sprite Defrag.
	elif objective_id == "compile_overclock":
		GameState.add_score(COMPILE_OVERCLOCK_BONUS_POINTS)
		_show_feedback("COMPILE CLUSTER OVERCLOCKED", Color(0.3, 1, 0.4, 1))
		objectives.get_objective("compile_overclock").reset() ## Charge-style — repeats, same pattern as Sprite Defrag.
	elif objective_id == "standup_bank":
		GameState.add_score(STANDUP_BANK_BONUS_POINTS)
		_show_feedback("BANK CLEARED", Color(1, 0.5, 0.9, 1))
		$UpperZone/MidZone/TimedGate.trigger_open()
		objectives.get_objective("standup_bank").reset() ## Flash-recover targets, unlike Firewall's drop bank — safe to repeat immediately.
	elif objective_id == "saucer_double":
		GameState.add_score(SAUCER_DOUBLE_BONUS_POINTS)
		_show_feedback("DUAL CAPTURE", Color(0.9, 0.3, 1, 1))
		objectives.get_objective("saucer_double").reset() ## Each saucer can be hit again any time — safe to repeat immediately.
	elif objective_id == "mini_target_cluster":
		GameState.add_score(MINI_TARGET_CLUSTER_BONUS_POINTS)
		_show_feedback("MINI TARGETS CLEARED", Color(1, 0.5, 0.9, 1))
		$UpperZone/MidZone/CollapsingBridge.trigger_collapse()
		objectives.get_objective("mini_target_cluster").reset() ## Flash-recover targets — safe to repeat immediately.
	elif objective_id == "captive_dual":
		GameState.add_score(CAPTIVE_DUAL_BONUS_POINTS)
		_show_feedback("CAPTIVE LOCK", Color(0.9, 0.9, 1, 1))
		objectives.get_objective("captive_dual").reset() ## Each captive ball can be struck again any time — safe to repeat immediately.
		_glitch_core.raise_gate(2)

func _on_core_hit_while_charged() -> void:
	## Closes the repair loop: rebuild the shaders, then cash it in at the
	## Core. Resets both the Core's own state and the underlying shader
	## objective (which otherwise stays "complete" forever and silently
	## ignores further hits) so the whole sequence can be run again.
	_glitch_core.charged = false
	GameState.add_score(CORE_CHARGED_HIT_POINTS)
	_show_feedback("CORE STABILIZED", Color(0.2, 1, 0.5, 1))
	objectives.get_objective("shader_rebuild").reset()
	_glitch_core.raise_gate(0)

func _on_reality_break_ready() -> void:
	## All 3 Glitch Core gates raised (see rotating_toy.gd): the wizard-mode-
	## style readiness check has passed. Fire the reward once, then reset
	## the gates so the whole climb can be repeated in the same session,
	## same pattern as every other repeatable bonus objective on this table.
	GameState.add_score(REALITY_BREAK_BONUS_POINTS)
	_show_feedback("REALITY BREAK", Color(1, 0.2, 0.6, 1))
	var zap: Node2D = GlitchZapScene.instantiate()
	zap.global_position = _glitch_core.global_position
	add_child(zap)
	start_multiball(REALITY_BREAK_BALL_COUNT, $PhysicsPrototype/Ball.position, REALITY_BREAK_LAUNCH_VELOCITY)
	_glitch_core.reset_gates()

func _on_clock_lane_hit(_target_id: String) -> void:
	## Direct trigger, not a multi-step objective -- a real pinball lane like
	## this just scores/lights on its own, no sequence to track.
	GameState.add_score(CLOCK_LANE_POINTS)
	_show_feedback("CLOCK SYNC", Color(0.3, 0.9, 1, 1))

func _on_objective_sequence_reset(objective_id: String) -> void:
	if objective_id != "shader_rebuild":
		return
	## Wrong-order hit — make the reset visible instead of silently doing
	## nothing, which read as "broken" rather than "wrong shot."
	for target in $ShaderNodeTargets.get_children():
		target.flash(Color(1, 0.2, 0.2, 1), 0.25)
	_show_feedback("SEQUENCE RESET — START OVER", Color(1, 0.3, 0.3, 1))

## Doubles the given points while Level 2 mode is active. Only wired to the
## upper-zone elements thematically tied to Level 2 (rollunder gate, cyber
## ramps, captive balls) -- not a blanket multiplier over every score call
## on the table.
func _award(points: int) -> void:
	GameState.add_score(points * LEVEL2_SCORE_MULTIPLIER if _level2_active else points)

func _start_level2_mode() -> void:
	if _level2_active:
		return
	_level2_active = true
	_show_feedback("LEVEL 2 ACTIVE — 2X SCORING", Color(0.9, 0.3, 1, 1))
	await get_tree().create_timer(LEVEL2_DURATION_SECONDS).timeout
	_level2_active = false
	_show_feedback("LEVEL 2 ENDED", Color(0.5, 0.5, 0.6, 1))

func _show_feedback(text: String, color: Color) -> void:
	_feedback_label.text = text
	_feedback_label.add_theme_color_override("font_color", color)
	_feedback_label.visible = true
	_debug_terminal.log_event(text)
	await get_tree().create_timer(2.0).timeout
	_feedback_label.visible = false

## Debug-only shot teleport, for deterministic testing of specific targets
## (e.g. the saucers, the loop mouth) without relying on lucky flipper-
## cascade RNG to reach them. Disabled entirely in release exports.
func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var ball: RigidBody2D = $PhysicsPrototype/Ball
	match event.keycode:
		KEY_1:
			ball.request_teleport($Saucer.global_position)
			_debug_terminal.log_event("> debug teleport: saucer")
		KEY_2:
			ball.request_teleport($Saucer2.global_position)
			_debug_terminal.log_event("> debug teleport: saucer2")
		KEY_3:
			## Placed just below the mouth with upward velocity so it actually
			## climbs into the cap, rather than just sitting in the channel --
			## a static teleport wouldn't test the cap-rattle behavior at all.
			ball.request_teleport(Vector2(362, 440), Vector2(0, -600))
			_debug_terminal.log_event("> debug teleport: loop shot (into channel, moving up)")
		KEY_4:
			## UpperZone content -- lets Cowork verify Level 2 mode (and
			## everything downstream of it) independent of the shooter lane
			## fix, since normal play can't reach here until that's sorted.
			ball.request_teleport($UpperZone/MidZone/VukToLevel2.global_position)
			_debug_terminal.log_event("> debug teleport: VUK to Level 2")
		KEY_5:
			ball.request_teleport($UpperZone/CrossoverZone/RollunderGate.global_position)
			_debug_terminal.log_event("> debug teleport: rollunder gate")
		KEY_6:
			ball.request_teleport($UpperZone/CrossoverZone/RampAEntrance.global_position)
			_debug_terminal.log_event("> debug teleport: cyber ramp A entrance")
		KEY_7:
			## Offset above the captive ball with downward velocity so it
			## actually collides with it, rather than teleporting into the
			## exact same position and overlapping.
			ball.request_teleport(Vector2(190, -1390), Vector2(0, 300))
			_debug_terminal.log_event("> debug teleport: captive ball 1 (falling toward it)")

# Built with assistance from Claude Code by Anthropic.
