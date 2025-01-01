extends Area2D

func start_dialog():
	var dialog = Dialogic.start("suscookie")
	dialog.pause_mode = PAUSE_MODE_PROCESS
	get_parent().add_child(dialog)
	dialog.connect("timeline_end", self, "end_dialog")
	get_tree().paused = true
	
func end_dialog(data):
	get_tree().paused = false
	queue_free()

func _on_cookie_body_entered(body):
	if body.is_in_group("Player"):
		start_dialog()

func _on_cookie_body_exited(body):
	if body.is_in_group("Player"):
		body.take_damage(105)
