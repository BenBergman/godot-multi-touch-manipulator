extends Node2D


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.double_tap or event is InputEventKey:
		$MouseToMultiTouch.remove_all_touch_points()
		for child in find_children("*", "MultiTouchManipulator"):
			child.go_home()
