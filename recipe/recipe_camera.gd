extends Camera2D

@export var zoom_step: float = 1.1

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("camera_grab"):
			position -= event.relative / zoom
			# get_viewport().set_input_as_handled()
	else:
		if Input.is_action_just_pressed("zoom_in"):
			zoom_at_mouse(zoom_step)
		elif Input.is_action_just_pressed("zoom_out"):
			zoom_at_mouse(1.0 / zoom_step)

func zoom_at_mouse(factor: float) -> void:
	var mouse_before = get_global_mouse_position()
	var new_zoom = zoom.x * factor
	zoom = Vector2(new_zoom, new_zoom)

	force_update_scroll()

	var mouse_after = get_global_mouse_position()
	global_position += mouse_before - mouse_after

	force_update_scroll()
