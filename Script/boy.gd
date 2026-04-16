extends Node2D

signal food_added
signal water_drunk

@onready var mouth = $Mouth
@onready var Open_Mouth = $"Open Mouth"
@onready var Closed_Mouth = $"Default"
@onready var Eating = $"Eating"
@onready var Drinking = $"Drinking"
@onready var Win = $"Win"
@onready var EatingChicken = $"Eating Chicken"
@onready var EatingRice = $"Eating Rice"
@onready var EatingVeggies = $"Eating Veggies"
@onready var EatAudio = $"Nguya(updated)"
@onready var DrinkAudio = $BreatheOut
@onready var SipAudio = $Sip
@onready var EndAudio = $WinAudio
@onready var Drinking_2 = $"Drinking water"

# Dictionary to store dragged food data
var food_data = {}
var is_eating = false
var glass_position = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Closed_Mouth.visible = true
	Open_Mouth.visible = false
	Eating.visible = false
	Drinking.visible = false
	Win.visible = false
	EatingChicken.visible = false
	EatingRice.visible = false
	EatingVeggies.visible = false
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
		
		# Store glass position if it's water
		if food.is_in_group("water"):
			glass_position = food.global_position
		
		food.queue_free()  # Remove the food after eating
		# Check if it's water to play drinking animation
		if food.is_in_group("water"):
			await play_drink_animation()
		else:
			var food_name = data.get("name", "")
			get_tree().create_timer(0.5).timeout.connect(func(): EatAudio.play(true))
			await play_eat_animation(food_name)


func play_eat_animation(food_name: String) -> void:
	is_eating = true
	Open_Mouth.visible = false
	Closed_Mouth.visible = false
	
	# Hide all food sprites first
	EatingChicken.visible = false
	EatingRice.visible = false
	EatingVeggies.visible = false
	
	# Show and play the appropriate sprite based on food type
	if food_name == "chicken":
		EatingChicken.visible = true
		EatingChicken.play("default")
		await EatingChicken.animation_finished
		EatingChicken.visible = false
	elif food_name == "rice":
		EatingRice.visible = true
		EatingRice.play("default")
		await EatingRice.animation_finished
		EatingRice.visible = false
	elif food_name == "veggie":
		EatingVeggies.visible = true
		EatingVeggies.play("default")
		await EatingVeggies.animation_finished
		EatingVeggies.visible = false
	
	Closed_Mouth.visible = true
	is_eating = false


func play_drink_animation() -> void:
	is_eating = true
	Open_Mouth.visible = false
	Closed_Mouth.visible = false
	Drinking.visible = false
	Drinking_2.visible = true
	Drinking_2.play("default")
	await Drinking_2.animation_finished
	Drinking_2.visible = false
	water_drunk.emit()
	# Play win animation
	Win.visible = true
	Win.play("Win")
	EndAudio.play(true)
	# Wait for WinAudio to finish
	await EndAudio.finished
	print("game done")
	get_tree().quit()


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
