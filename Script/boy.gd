extends Node2D

signal food_added

@onready var mouth = $Mouth
@onready var Open_Mouth = $"Open Mouth"
@onready var Closed_Mouth = $"Default"
@onready var Eating = $"Eating"
@onready var Drinking = $"Drinking"
@onready var Win = $"Win"
@onready var EatAudio = $"Nguya(updated)"
@onready var DrinkAudio = $BreatheOut
@onready var SipAudio = $Sip
@onready var EndAudio = $WinAudio
# Dictionary to store dragged food data
var food_data = {}
var is_eating = false
var reward_scene = preload("res://Scene/reward_screen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Closed_Mouth.visible = true
	Open_Mouth.visible = false
	Eating.visible = false
	Drinking.visible = false
	Win.visible = false
	mouth.area_entered.connect(_on_mouth_area_entered)
	mouth.body_entered.connect(_on_mouth_body_entered)
	mouth.area_exited.connect(_on_mouth_area_exited)
	mouth.body_exited.connect(_on_mouth_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_mouth_area_entered(area: Area2D):
	# Check if water is being dragged
	var parent = area.get_parent()
	if parent and parent.is_in_group("water") and parent.dragging:
		if not is_eating:
			Open_Mouth.visible = false
			Closed_Mouth.visible = false
			Drinking.visible = true
			Drinking.play("anim 1")
			SipAudio.play(true)
		return
	# Open mouth on hover for other foods
	if not is_eating:
		Open_Mouth.visible = true
		Closed_Mouth.visible = false


func _on_mouth_body_entered(_body: Node2D):
	# Open mouth on hover
	if not is_eating:
		Open_Mouth.visible = true
		Closed_Mouth.visible = false


func _on_mouth_area_exited(area: Area2D):
	# Check if water is exiting
	var parent = area.get_parent()
	if parent and parent.is_in_group("water"):
		if not is_eating:
			Drinking.visible = false
			Closed_Mouth.visible = true
		return
	if not is_eating:
		Open_Mouth.visible = false
		Closed_Mouth.visible = true


func _on_mouth_body_exited(_body: Node2D):
	if not is_eating:
		Open_Mouth.visible = false
		Closed_Mouth.visible = true


func eat_food(food: Node2D):
	# Get and store food data
	if food.has_method("get_food_data"):
		var data = food.get_food_data()
		store_food(data)
		food.queue_free()  # Remove the food after eating
		# Check if it's water to play drinking animation
		if food.is_in_group("water"):
			DrinkAudio.play(true)
			await play_drink_animation()
		else:
			EatAudio.play(true)
			await play_eat_animation()
			


func play_eat_animation() -> void:
	is_eating = true
	Open_Mouth.visible = false
	Closed_Mouth.visible = false
	Eating.visible = true
	Eating.play("Eating")
	await Eating.animation_finished
	Eating.visible = false
	Closed_Mouth.visible = true
	is_eating = false


func play_drink_animation() -> void:
	is_eating = true
	Open_Mouth.visible = false
	Closed_Mouth.visible = false
	Drinking.visible = true
	Drinking.play("anim 2")
	await Drinking.animation_finished
	Drinking.visible = false
	# Play win animation
	Win.visible = true
	Win.play("Win")
	EndAudio.play(true)
	# Wait for WinAudio to finish
	await EndAudio.finished
	# Load reward scene on top of main
	var reward = reward_scene.instantiate()
	get_tree().root.add_child(reward)
	# Unload main scene
	get_tree().root.remove_child(get_parent())
	get_parent().queue_free()


func store_food(data: Dictionary):
	# Store the food data
	if data.has("name"):
		var food_name = data["name"]
		if food_data.has(food_name):
			food_data[food_name]["count"] += 1
		else:
			food_data[food_name] = {
				"count": 1,
				"type": data.get("type", "unknown"),
				"nutrition": data.get("nutrition", 0)
			}
		print("Food stored: ", food_name, " | Total eaten: ", food_data[food_name]["count"])
		print("All food data: ", food_data)
		food_added.emit()
