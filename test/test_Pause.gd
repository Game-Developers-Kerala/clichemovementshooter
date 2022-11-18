extends CanvasLayer

func _ready():
	hide()

func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			show()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			hide()
