extends Control

# ============================================================
# CONSTANTS
# ============================================================


# ============================================================
# ONREADY VARIABLES
# ============================================================

@onready var goodjob = $GoodJob
@onready var victory = $"VictorySoundEffect(mp3Cut_net)"
@onready var next_button = $"CanvasLayer/Control/Next"
@onready var next_label = $"CanvasLayer/Control/Next"

var base_view_size := Vector2.ZERO
var base_root_scale := Vector2.ONE

# ============================================================
# LIFECYCLE METHODS
# ============================================================

func _ready() -> void:
	_cache_base_layout()
	_apply_responsive_layout()
	get_viewport().size_changed.connect(_apply_responsive_layout)

	if next_button:
		next_button.pressed.connect(_on_next_pressed)
	
	_show_stars_sequence()
	victory.play()
	await victory.finished
	goodjob.play()

func _cache_base_layout() -> void:
	base_view_size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	base_root_scale = scale
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	if base_view_size.x > 0.0 and base_view_size.y > 0.0:
		size = base_view_size

func _apply_responsive_layout() -> void:
	var view_size = get_viewport().get_visible_rect().size
	if view_size.x <= 0.0 or view_size.y <= 0.0:
		return
	if base_view_size.x <= 0.0 or base_view_size.y <= 0.0:
		return

	# Scale the entire UI to preserve the original layout across devices.
	var scale_factor = min(view_size.x / base_view_size.x, view_size.y / base_view_size.y)
	scale = base_root_scale * scale_factor
	var scaled_size = base_view_size * scale_factor
	position = (view_size - scaled_size) * 0.5

# ============================================================
# STAR ANIMATION METHODS
# ============================================================

func _show_stars_sequence() -> void:
	var star_left = get_node_or_null("CanvasLayer/Control/Star Left")
	var star_middle = get_node_or_null("CanvasLayer/Control/Star Middle")
	var star_right = get_node_or_null("CanvasLayer/Control/Star Right")
	
	var stars = [star_left, star_middle, star_right]
	
	for star in stars:
		if star:
			star.visible = true
	
	for star in stars:
		if star:
			_start_star_pulse(star)

func _start_star_pulse(star: Node) -> void:
	var timer = Timer.new()
	timer.one_shot = true
	star.add_child(timer)
	timer.timeout.connect(func():
		_run_star_pulse(star, timer)
	)
	timer.start(randf_range(1.0, 2.5))

func _run_star_pulse(star: Node, timer: Timer) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(star, "scale", Vector2(0.4, 0.4), 0.4)
	tween.tween_property(star, "scale", Vector2(0.3, 0.3), 0.4)
	tween.finished.connect(func():
		if is_instance_valid(timer):
			timer.start(randf_range(1.0, 2.5))
	)

# ============================================================
# BUTTON CALLBACKS
# ============================================================

func _on_next_pressed() -> void:
	get_tree().quit()
