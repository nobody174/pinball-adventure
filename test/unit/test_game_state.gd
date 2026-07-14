extends GutTest

## GameState is an autoload (global singleton) — tests drive it directly
## rather than instantiating a fresh copy, so each test resets what it
## touches instead of assuming a blank slate.

const TEST_TABLE_ID := "__test_table__"

func before_each() -> void:
	## High scores persist to a real file, so a stale entry from a previous
	## run would otherwise leak into these tests -- clear it every time.
	GameState._high_scores.erase(TEST_TABLE_ID)

func after_each() -> void:
	GameState.reset_score()
	GameState._high_scores.erase(TEST_TABLE_ID)
	GameState._save_high_scores()

func test_add_score_accumulates() -> void:
	GameState.reset_score()
	GameState.add_score(100)
	GameState.add_score(50)
	assert_eq(GameState.score, 150)

func test_add_score_emits_signal_with_new_total() -> void:
	GameState.reset_score()
	watch_signals(GameState)
	GameState.add_score(100)
	assert_signal_emitted_with_parameters(GameState, "score_changed", [100])

func test_reset_score_zeroes_and_emits() -> void:
	GameState.add_score(500)
	watch_signals(GameState)
	GameState.reset_score()
	assert_eq(GameState.score, 0)
	assert_signal_emitted_with_parameters(GameState, "score_changed", [0])

func test_unknown_table_has_zero_high_score() -> void:
	assert_eq(GameState.get_high_score(TEST_TABLE_ID), 0)

func test_submit_score_becomes_new_high_score_when_higher() -> void:
	var is_new: bool = GameState.submit_score(TEST_TABLE_ID, 1000)
	assert_true(is_new)
	assert_eq(GameState.get_high_score(TEST_TABLE_ID), 1000)

func test_submit_score_does_not_overwrite_a_higher_existing_score() -> void:
	GameState.submit_score(TEST_TABLE_ID, 1000)
	var is_new: bool = GameState.submit_score(TEST_TABLE_ID, 500)
	assert_false(is_new)
	assert_eq(GameState.get_high_score(TEST_TABLE_ID), 1000)
