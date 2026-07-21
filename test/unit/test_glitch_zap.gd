extends GutTest

const GlitchZapScene := preload("res://tables/the_glitch/fx/glitch_zap.tscn")

func _make_zap(lifetime_seconds: float = 0.5) -> Node2D:
	var zap: Node2D = GlitchZapScene.instantiate()
	zap.lifetime_seconds = lifetime_seconds ## Set before add_child so _ready() picks it up directly, no re-invoking _ready().
	add_child_autofree(zap)
	return zap

func test_generates_points_on_process() -> void:
	var zap := _make_zap()

	zap._process(0.0)

	assert_gt(zap._points.size(), 0, "should generate a jagged polyline on process")

func test_frees_itself_after_lifetime() -> void:
	var zap := _make_zap(0.05)

	await wait_seconds(0.15)

	assert_true(not is_instance_valid(zap) or zap.is_queued_for_deletion(), "zap should free itself once its timer elapses")

func test_regenerates_different_points_each_process_call() -> void:
	## Not a strict guarantee (random jitter could theoretically repeat),
	## but with continuous jitter across 9 segments a full match is
	## astronomically unlikely -- this is really checking that _process
	## rebuilds the array rather than reusing a stale one.
	var zap := _make_zap()

	zap._process(0.0)
	var first_points: PackedVector2Array = zap._points.duplicate()
	zap._process(0.0)
	var second_points: PackedVector2Array = zap._points

	assert_ne(first_points, second_points, "each process call should regenerate jittered points")
