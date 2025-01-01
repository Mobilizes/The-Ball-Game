extends Area2D

export var dialog_index : int

func _ready():
	add_to_group("void")

func start_dialog():
	var dialog = Dialogic.start("monologue" + str(dialog_index))
	dialog.pause_mode = PAUSE_MODE_PROCESS
	get_parent().add_child(dialog)
	dialog.connect("timeline_end", self, "end_dialog")
	get_tree().paused = true
	
func end_dialog(data):
	get_tree().paused = false
	$collectsfx.play()
	yield($collectsfx, "finished")
	queue_free()

func _on_VoidShard_body_entered(body):
	if body.is_in_group("Player"):
		dialog_index = body.voidshard_collect()
		body.checkpoint = self.position
		start_dialog()
		Input.action_release("jump")
