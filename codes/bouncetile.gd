extends Area2D


func _on_BounceTile_body_entered(body):
	if body.is_in_group("Player"):
		body.bounce()
		$bouncesfx.play()
