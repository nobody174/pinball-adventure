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

const SHADER_TARGET_POINTS := 100
const CORE_CHARGED_HIT_POINTS := 1000
const CORE_UNCHARGED_HIT_POINTS := 50
const SLINGSHOT_POINTS := 25
const BUMPER_POINTS := 50
const CACHE_BUMPER_POINTS := 50
const SPRITE_DEFRAG_BONUS_POINTS := 750

@onready var _feedback_label: Label = $Feedback/Label
@onready var _score_label: Label = $Feedback/ScoreLabel
@onready var _high_score_label: Label = $Feedback/HighScoreLabel
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
	])
	objective_completed.connect(_on_objective_completed)
	objective_sequence_reset.connect(_on_objective_sequence_reset)
	for target in $ShaderNodeTargets.get_children():
		target.hit.connect(func(_id: String) -> void: GameState.add_score(SHADER_TARGET_POINTS))
		target.hit.connect(register_target_hit)
	for bumper in $SpriteCacheBumpers.get_children():
		var kick_area: Area2D = bumper.get_node("KickArea")
		kick_area.hit.connect(func(_id: String) -> void: GameState.add_score(CACHE_BUMPER_POINTS))
		kick_area.hit.connect(register_target_hit)
	_glitch_core.hit_while_charged.connect(_on_core_hit_while_charged)
	_glitch_core.hit_while_uncharged.connect(func() -> void: GameState.add_score(CORE_UNCHARGED_HIT_POINTS))
	$LeftSlingshot.kicked.connect(func() -> void: GameState.add_score(SLINGSHOT_POINTS))
	$RightSlingshot.kicked.connect(func() -> void: GameState.add_score(SLINGSHOT_POINTS))
	$PhysicsPrototype/Bumper/KickArea.kicked.connect(func() -> void: GameState.add_score(BUMPER_POINTS))

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

func _on_core_hit_while_charged() -> void:
	## Closes the repair loop: rebuild the shaders, then cash it in at the
	## Core. Resets so the whole sequence can be run again.
	_glitch_core.charged = false
	GameState.add_score(CORE_CHARGED_HIT_POINTS)
	_show_feedback("CORE STABILIZED", Color(0.2, 1, 0.5, 1))

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
	await get_tree().create_timer(2.0).timeout
	_feedback_label.visible = false
