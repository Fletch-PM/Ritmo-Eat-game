extends Node

var base_view_size = Vector2.ZERO
var base_positions = {}
var base_camera_limits = {}

var camera: Camera2D
var spawn_marker: Marker2D
var plate_mid_marker: Marker2D
var plate_start_marker: Marker2D
var plate_end_marker: Marker2D
var food_destination: Marker2D
var extended_bg: Sprite2D
var window_sprite: Sprite2D


func initialize(
	p_camera: Camera2D,
	p_spawn_marker: Marker2D,
	p_plate_mid_marker: Marker2D,
	p_plate_start_marker: Marker2D,
	p_plate_end_marker: Marker2D,
	p_food_destination: Marker2D,
	p_extended_bg: Sprite2D,
	p_window_sprite: Sprite2D
) -> void:
	camera = p_camera
	spawn_marker = p_spawn_marker
	plate_mid_marker = p_plate_mid_marker
	plate_start_marker = p_plate_start_marker
	plate_end_marker = p_plate_end_marker
	food_destination = p_food_destination
	extended_bg = p_extended_bg
	window_sprite = p_window_sprite
	
	cache_base_layout()


func cache_base_layout() -> void:
	base_view_size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	base_positions = {
		"camera": camera.position,
		"food_destination": food_destination.position,
		"spawn": spawn_marker.position,
		"plate_mid": plate_mid_marker.position,
		"plate_start": plate_start_marker.position,
		"plate_end": plate_end_marker.position,
		"extended_bg": extended_bg.position,
		"window": window_sprite.position
	}
	base_camera_limits = {
		"left": camera.limit_left,
		"top": camera.limit_top,
		"right": camera.limit_right,
		"bottom": camera.limit_bottom
	}


func apply_responsive_layout(viewport: Viewport) -> void:
	var view_size = viewport.get_visible_rect().size
	if view_size.x <= 0.0 or view_size.y <= 0.0:
		return

	# Keep the original world layout and scale the camera to fit the viewport.
	var zoom_x = base_view_size.x / view_size.x
	var zoom_y = base_view_size.y / view_size.y
	camera.zoom = Vector2(zoom_x, zoom_y)
	camera.position = base_positions["camera"]
	camera.limit_left = base_camera_limits["left"]
	camera.limit_top = base_camera_limits["top"]
	camera.limit_right = base_camera_limits["right"]
	camera.limit_bottom = base_camera_limits["bottom"]

	# Restore base positions so the camera is the sole source of responsiveness.
	spawn_marker.position = base_positions["spawn"]
	plate_mid_marker.position = base_positions["plate_mid"]
	plate_start_marker.position = base_positions["plate_start"]
	plate_end_marker.position = base_positions["plate_end"]
	food_destination.position = base_positions["food_destination"]
	extended_bg.position = base_positions["extended_bg"]
	window_sprite.position = base_positions["window"]
