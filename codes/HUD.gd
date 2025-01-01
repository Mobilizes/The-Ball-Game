extends CanvasLayer

func _on_Player_health_changed(new_health):
	$healthbar.value = new_health

func _on_Player_stamina_change(new_stamina):
	$staminabar.value = new_stamina
