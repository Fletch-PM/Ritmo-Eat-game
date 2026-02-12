extends Node2D

@onready var chicken_scene = preload("res://Scene/chicken.tscn")
@onready var rice_scene = preload("res://Scene/rice.tscn")
@onready var veggie_scene = preload("res://Scene/veggie.tscn")
@onready var glass_scene = preload("res://Scene/glass.tscn")
@onready var plate_scene = preload("res://Scene/plate.tscn")
@onready var food_destination = $"Food Destination"
@onready var spawn_marker = $"Spawn Marker"
@onready var plate_mid_marker = $"Plate Mid Marker"
@onready var plate_start_marker = $"Plate Start Marker"
@onready var plate_end_marker = $"Plate End Marker"
@onready var boy = $Boy
@onready var bg_music = $EatGameBg
@onready var back_button = $"Back"

var plate_mid = null
var plate_start = null
var rice_on_start = null
var veggie_on_start = null
var glass_spawned = false
var glass = null
var food_eaten_count = 0
var plate_counter = 0
var max_plates = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Make camera active
	var camera = $Camera2D
	camera.make_current()
	
	# Setup background music looping
	bg_music.finished.connect(_on_bg_music_finished)
	
	# Connect back button
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	spawn_initial_plates()
	spawn_chicken()
	spawn_rice()
	boy.food_added.connect(_on_food_added)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func spawn_chicken():
	var chicken = chicken_scene.instantiate()
	chicken.position = food_destination.position
	add_child(chicken)


func spawn_rice():
	var rice = rice_scene.instantiate()
	rice.position = spawn_marker.position
	add_child(rice)
	rice_on_start = rice


func spawn_glass():
	glass = glass_scene.instantiate()
	glass.position = spawn_marker.position
	add_child(glass)
	glass_spawned = true


func spawn_initial_plates():
	# Spawn first plate at mid marker
	plate_mid = plate_scene.instantiate()
	plate_mid.position = plate_mid_marker.position
	add_child(plate_mid)
	plate_counter += 1
	print("Plate spawned at mid: ", plate_counter, "/", max_plates)
	
	# Spawn second plate at start marker
	plate_start = plate_scene.instantiate()
	plate_start.position = plate_start_marker.position
	add_child(plate_start)
	plate_counter += 1
	print("Plate spawned at start: ", plate_counter, "/", max_plates)


func spawn_plate_at_start():
	if plate_counter < max_plates:
		plate_start = plate_scene.instantiate()
		plate_start.position = plate_start_marker.position
		add_child(plate_start)
		plate_counter += 1
		print("Plate spawned at start: ", plate_counter, "/", max_plates)
		
		# Spawn veggie with the third plate
		if plate_counter == 3:
			var veggie = veggie_scene.instantiate()
			veggie.position = spawn_marker.position
			add_child(veggie)
			veggie_on_start = veggie
			print("Veggie spawned with third plate")


func _on_food_added():
	food_eaten_count += 1

	if plate_mid:
		# Move the mid plate to end marker
		var tween = create_tween()
		tween.tween_property(plate_mid, "position", plate_end_marker.position, 2.0)
		await tween.finished
		plate_mid.queue_free()
		plate_mid = null
		
		# Move glass after 3rd plate reaches end marker
		if food_eaten_count == 3 and glass:
			var glass_tween = create_tween()
			glass_tween.tween_property(glass, "position", food_destination.position, 1.0)
			await glass_tween.finished
			# Update glass home position after move
			if "home_position" in glass:
				glass.home_position = glass.global_position
		
		# Move start plate to mid marker
		if plate_start:
			plate_mid = plate_start
			var move_tween = create_tween()
			move_tween.tween_property(plate_mid, "position", plate_mid_marker.position, 1.0)
			
			# Move rice with the plate from start to mid
			if rice_on_start:
				var rice_offset = rice_on_start.position - plate_start.position
				var rice_tween = create_tween()
				rice_tween.tween_property(rice_on_start, "position", plate_mid_marker.position + rice_offset, 1.0)
				await rice_tween.finished
				# Update rice home position
				rice_on_start.home_position = rice_on_start.global_position
				rice_on_start = null
			
			# Move veggie with the plate from start to mid
			if veggie_on_start:
				var veggie_offset = veggie_on_start.position - plate_start.position
				var veggie_tween = create_tween()
				veggie_tween.tween_property(veggie_on_start, "position", plate_mid_marker.position + veggie_offset, 1.0)
				await veggie_tween.finished
				# Update veggie home position
				veggie_on_start.home_position = veggie_on_start.global_position
				veggie_on_start = null
				if not glass_spawned:
					spawn_glass()
			
			plate_start = null
			
			# Spawn new plate at start marker
			spawn_plate_at_start()


func _on_bg_music_finished() -> void:
	# Replay background music when it finishes
	bg_music.play()


func _on_back_pressed() -> void:
	get_tree().quit()
