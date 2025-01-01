extends Area2D


func _on_Teleporter_body_entered(body):
	if body.is_in_group("Player"):
		body.position = body.teleport()
		$teleportsfx.play()
