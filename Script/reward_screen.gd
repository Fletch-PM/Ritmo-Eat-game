extends Control

# ============================================================
# CONSTANTS
# ============================================================


# ============================================================
# ONREADY VARIABLES
# ============================================================

@onready var goodjob = $GoodJob
@onready var victory = $"VictorySoundEffect(mp3Cut_net)"
@onready var next_button = $"Next"
@onready var next_label = $"Next"

# ============================================================
# LIFECYCLE METHODS
# ============================================================

func _ready() -> void:
	if next_button:
		next_button.pressed.connect(_on_next_pressed)
	
	_show_stars_sequence()
	victory.play()
	await victory.finished
	goodjob.play()

# ============================================================
# STAR ANIMATION METHODS
# ============================================================

func _show_stars_sequence() -> void:
	var star_left = get_node_or_null("Star Left")
	var star_middle = get_node_or_null("Star Middle")
	var star_right = get_node_or_null("Star Right")
	
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
