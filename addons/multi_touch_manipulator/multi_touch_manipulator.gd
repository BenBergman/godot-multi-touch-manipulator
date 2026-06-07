@tool
@icon ("res://addons/multi_touch_manipulator/at-icons/node2d/pointer.svg")

class_name MultiTouchManipulator
extends Node2D

@export_group("Sprite")
## Texture for internal Sprite2D
@export var texture: Texture2D:
	set(tex):
		texture = tex
		update_texture()
		update_bounding_rect()
## Optional bitmap mask to limit clickable region
@export var click_mask: BitMap:
	set(mask):
		click_mask = mask
		update_click_mask()
## Optional bounding box size to constrain sprite in.
## Useful for loading arbitrarily sized textures that may be zoomed in a lot to see detail.
@export var bounding_rect: Vector2:
	set(r):
		bounding_rect = r
		update_bounding_rect()

@export_group("Debug")
## Enables drawing each touch point, bounding boxes, and transform visualization lines
@export_flags("Touches:1", "Motions:2", "Bounds:4", "Transform:8") var debug_draw_flags = 0
const F_TOUCHES := 1
const F_MOTIONS := 2
const F_BOUNDS := 4
const F_TRANSFORM := 8


@onready var item := $Container as Node2D
@onready var control := $Container/TextureButton as TextureButton
var home: Transform2D


class Touch:
	# Position relative to space the base node's position is in
	var start_position: Vector2
	var position: Vector2

	# Record start of touch so we can react to short taps, long holds, etc.
	var start_time_msec: int


	func _init(pos: Vector2, parent_transform: Transform2D):
		update(pos, parent_transform)
		reset_home()
		start_time_msec = Time.get_ticks_msec()


	func update(pos: Vector2, parent_transform: Transform2D) -> void:
		# Shift touch position (oniginally relative to viewport) and adjusts to be local to the touch manipulator
		# Likely need to use get_screen_transform, get_global_transform_with_canvas, etc. from the CanvasItem if it is embedded in something else
		# See the diagram here: https://docs.godotengine.org/en/stable/engine_details/architecture/2d_coordinate_systems.html#godot-2d-coordinate-systems
		position = parent_transform * pos


	func reset_home() -> void:
		start_position = position




var touches: Dictionary[int, Touch] = {}
var start_position: Vector2
var start_transform: Transform2D


func _ready():
	control.gui_input.connect(_on_gui_input)
	update_texture()
	update_click_mask()
	update_bounding_rect()
	home = item.transform # must be after `update_bounding_rect` to capture scale


func _draw() -> void:
	if debug_draw_flags or Engine.is_editor_hint():
		if debug_draw_flags & F_TRANSFORM and touches.size() > 0:
			# Line from sprite start location to current
			draw_line(start_position, item.position, Color.BLUE, 5.0 / scale.x, true)
		for touch in touches.values():
			var pos = touch.position
			if debug_draw_flags & F_MOTIONS:
				draw_line(touch.start_position, touch.position, Color.RED, 5.0 / scale.x, true)
			if debug_draw_flags & F_TOUCHES:
				draw_circle(pos, 30.0 / scale.x, Color.DODGER_BLUE)
				draw_circle(pos, 100.0 / scale.x, Color(Color.DODGER_BLUE, 0.3))
		if debug_draw_flags & F_BOUNDS and bounding_rect:
			# Home size and location of object
			draw_rect(Rect2(-bounding_rect/2.0, bounding_rect), Color.BLUE, false)

			# Current size and location of object
			var t = item.transform
			draw_set_transform(t.get_origin(), t.get_rotation())
			draw_rect(Rect2(-bounding_rect/2.0, bounding_rect), Color.GREEN, false)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			move_to_front()
			if event.double_tap:
				go_home()
			touches[event.index] = Touch.new(event.position - control.size / 2.0, item.transform)
		else:
			touches.erase(event.index)

		if touches.size() == 1 or touches.size() == 2:
			reset_start_positions()

		queue_redraw()

	elif event is InputEventScreenDrag and touches.has(event.index):
		touches[event.index].update(event.position - control.size / 2.0, item.transform)

		var t1 = touches.values()[0]

		if touches.size() == 1:
			var old_t := Transform2D(Vector2.RIGHT, Vector2.DOWN, t1.start_position)
			var new_t := Transform2D(Vector2.RIGHT, Vector2.DOWN, t1.position)
			item.transform = new_t * old_t.affine_inverse() * start_transform
		elif touches.size() == 2:
			var t2 = touches.values()[1]
			# TODO: maybe want to pre-calculate the old transform or store updated
			# "start" values after updating transform so we don't even need the
			# original values?
			var old_x : Vector2 = t2.start_position - t1.start_position
			var old_t := Transform2D(old_x, old_x.rotated(PI/2.0), t1.start_position)
			var new_x : Vector2 = t2.position - t1.position
			var new_t := Transform2D(new_x, new_x.rotated(PI/2.0), t1.position)
			item.transform = new_t * old_t.affine_inverse() * start_transform

		queue_redraw()


func go_home() -> void:
	item.transform = home
	queue_redraw()


func reset_start_positions() -> void:
	for touch in touches.values():
		touch.reset_home()
	start_position = item.position
	start_transform = item.transform


func update_texture() -> void:
	if control and texture:
		control.texture_normal = texture
		if not click_mask:
			control.texture_click_mask = null
		control.offset_left = -texture.get_size().x / 2.0
		control.offset_right = texture.get_size().x / 2.0
		control.offset_top = -texture.get_size().y / 2.0
		control.offset_bottom = texture.get_size().y / 2.0


func update_click_mask() -> void:
	if control and click_mask:
		control.texture_click_mask = click_mask


func update_bounding_rect() -> void:
	if item and bounding_rect:
		var proportion = bounding_rect / control.size
		item.scale = minf(proportion.x, proportion.y) * Vector2.ONE
		queue_redraw()
