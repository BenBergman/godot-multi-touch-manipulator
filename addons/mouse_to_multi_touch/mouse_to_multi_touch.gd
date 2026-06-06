@icon ("res://addons/mouse_to_multi_touch/at-icons/node2d/cursor.svg")

class_name MouseToMultiTouch
extends Node2D


# TODO: fake touch points don't move with content when window is resized
# - Probably need to store the non-transformed mouse position instead of the transformed one for drawing...?


@export var radius := 32.0


var mock_touches := {}
var index := 9000
var grabbed_point := 0


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed == false and event.button_index == 1:
		grabbed_point = 0
	if event is InputEventMouseButton and event.pressed == true and event.button_index == 1:
		var nearest_point = find_nearest_touch_point_in_range(_transform_mouse_to_touch_pos(event.position))
		if nearest_point:
			move_touch_point(nearest_point.index, _transform_mouse_to_touch_pos(event.position))
			grabbed_point = nearest_point.index
		else:
			grabbed_point = new_touch_point(_transform_mouse_to_touch_pos(event.position))
	if event is InputEventMouseButton and event.pressed == true and event.button_index == 2:
		var nearest_point = find_nearest_touch_point_in_range(_transform_mouse_to_touch_pos(event.position))
		if nearest_point:
			remove_touch_point(nearest_point)
		else:
			remove_all_touch_points()
	if event is InputEventMouseMotion and event.button_mask == 1:
		if grabbed_point > 0 and mock_touches.has(grabbed_point):
			move_touch_point(grabbed_point, _transform_mouse_to_touch_pos(event.position))
	if event is InputEventScreenDrag or event is InputEventScreenTouch:
		#print("UNHANDLED TOUCH!!! ", event)
		pass


func find_nearest_touch_point_in_range(pos: Vector2, max_range: float = radius) -> InputEventScreenTouch:
	var min_distance := 99999999.0
	var point
	for touch in mock_touches.values():
		var touch_distance = pos.distance_to(touch.position)
		if touch_distance < max_range and touch_distance < min_distance:
			min_distance = touch_distance
			point = touch
	return point


func new_touch_point(pos: Vector2) -> int:
	var e := InputEventScreenTouch.new()
	e.window_id = get_window().get_window_id()
	e.index = index
	e.position = pos
	# TODO: detect double taps
	e.double_tap = false
	e.pressed = true
	get_viewport().push_input(e)
	mock_touches.set(index, e)
	index += 1
	queue_redraw()
	return e.index


func remove_touch_point(e: InputEventScreenTouch) -> void:
	e.window_id = get_window().get_window_id()
	e.pressed = false
	get_viewport().push_input(e)
	mock_touches.erase(e.index)
	queue_redraw()


func remove_all_touch_points() -> void:
	for touch in mock_touches.values():
		remove_touch_point(touch)


func move_touch_point(idx: int, pos: Vector2) -> void:
	mock_touches[idx].position = pos
	var e := InputEventScreenDrag.new()
	e.window_id = get_window().get_window_id()
	e.index = idx
	e.position = pos
	get_viewport().push_input(e)
	queue_redraw()


func _draw() -> void:
	var t := get_viewport().get_screen_transform().affine_inverse()
	for touch in mock_touches.values():
		draw_circle(t * touch.position, radius, Color.ORANGE, false, 3.0)

func _transform_mouse_to_touch_pos(pos: Vector2) -> Vector2:
	var new_pos = get_viewport().get_screen_transform() * pos
	return new_pos
