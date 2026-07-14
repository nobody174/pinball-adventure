extends PinballTable

## The Glitch — vertical slice. Table-specific wiring only: what "shader_a/
## b/c" mean and what happens when the objective completes. The objective
## system itself (core/objectives/) has no idea any of this exists.

const TABLE_ID := "the_glitch"

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

@onready var _feedback_label: Label = $Feedback/Label
@onready var _score_label: Label = $Feedback/ScoreLabel
@onready var _high_score_label: Label = $Feedback/HighScoreLabel
@onready var _debug_terminal: DebugTerminal = $Feedback/DebugTerminal
@onready var _glitch_core: Area2D = $GlitchCore

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
	$LeftSlingshot.kicked.connect(func() -> void: GameState.add_score(SLINGSHOT_POINTS))
	$RightSlingshot.kicked.connect(func() -> void: GameState.add_score(SLINGSHOT_POINTS))
	$PhysicsPrototype/Bumper/KickArea.kicked.connect(func() -> void: GameState.add_score(BUMPER_POINTS))
	$ClockLane.hit.connect(_on_clock_lane_hit)
	$Spinner.spun.connect(func(_id: String) -> void: GameState.add_score(SPINNER_POINTS))

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
	elif objective_id == "vram_throughput":
		GameState.add_score(VRAM_THROUGHPUT_BONUS_POINTS)
		_show_feedback("VRAM THROUGHPUT MAXED", Color(0.2, 1, 0.9, 1))
		objectives.get_objective("vram_throughput").reset() ## Charge-style — repeats, same pattern as Sprite Defrag.
	elif objective_id == "compile_overclock":
		GameState.add_score(COMPILE_OVERCLOCK_BONUS_POINTS)
		_show_feedback("COMPILE CLUSTER OVERCLOCKED", Color(0.3, 1, 0.4, 1))
		objectives.get_objective("compile_overclock").reset() ## Charge-style — repeats, same pattern as Sprite Defrag.

func _on_core_hit_while_charged() -> void:
	## Closes the repair loop: rebuild the shaders, then cash it in at the
	## Core. Resets both the Core's own state and the underlying shader
	## objective (which otherwise stays "complete" forever and silently
	## ignores further hits) so the whole sequence can be run again.
	_glitch_core.charged = false
	GameState.add_score(CORE_CHARGED_HIT_POINTS)
	_show_feedback("CORE STABILIZED", Color(0.2, 1, 0.5, 1))
	objectives.get_objective("shader_rebuild").reset()

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

func _show_feedback(text: String, color: Color) -> void:
	_feedback_label.text = text
	_feedback_label.add_theme_color_override("font_color", color)
	_feedback_label.visible = true
	_debug_terminal.log_event(text)
	await get_tree().create_timer(2.0).timeout
	_feedback_label.visible = false
