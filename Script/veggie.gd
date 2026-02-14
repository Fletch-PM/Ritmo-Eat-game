extends Node2D

var dragging = false
var being_eaten = false
var can_be_dragged = false
var home_position = Vector2.ZERO
@onready var veggie_area = get_node_or_null("Veggie Area") as Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if veggie_area == null:
		for child in get_children():
			if child is Area2D:
				veggie_area = child
				break
		if veggie_area == null:
			return
	veggie_area.input_event.connect(_on_input_event)
	# Store home position after being added to scene
	await get_tree().process_frame
	home_position = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position()


func _on_input_event(_viewport, event, _shape_idx):
	# Handle touch input for mobile
	if event is InputEventScreenTouch:
		if event.pressed and can_be_dragged:
			dragging = true
		else:
			dragging = false
			if can_be_dragged:
				_check_drop()


func _check_drop():
	# Check if dropped on mouth
	if being_eaten:
		return  # Already being eaten, don't process again
	if veggie_area == null:
		return
	
	var overlapping_areas = veggie_area.get_overlapping_areas()
	var dropped_on_mouth = false
	
	for area in overlapping_areas:
		if area.name == "Mouth":
			var boy = area.get_parent()
			if boy and boy.has_method("eat_food"):
				being_eaten = true
				boy.eat_food(self)
				dropped_on_mouth = true
			return
	
	# If not dropped on mouth, return to home position
	if not dropped_on_mouth:
		global_position = home_position


func get_food_data() -> Dictionary:
	return {
		"name": "veggie",
		"type": "vitamins",
		"nutrition": 60
	}
