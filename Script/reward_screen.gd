extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_show_stars_sequence()

func _show_stars_sequence() -> void:
	# Hide stars initially
	var star_left = get_node_or_null("Star Left")
	var star_middle = get_node_or_null("Star Middle")
	var star_right = get_node_or_null("Star Right")
	
	if star_left:
		star_left.visible = false
	if star_middle:
		star_middle.visible = false
	if star_right:
		star_right.visible = false
	
	# Show stars in sequence with 0.5 sec delay
	await get_tree().create_timer(1).timeout
	if star_left:
		star_left.visible = true
		print("✓ Star Left appeared!")
	
	await get_tree().create_timer(1).timeout
	if star_middle:
		star_middle.visible = true
		print("✓ Star Middle appeared!")
	
	await get_tree().create_timer(1).timeout
	if star_right:
		star_right.visible = true
		print("✓ Star Right appeared!")
